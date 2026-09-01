import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/catalog/catalog_bloc.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/item_card.dart';
import '../shared/widgets/ui_kit.dart';

/// Каталог товаров.
///
/// Доступен без авторизации: покупатель может листать предопределённый
/// набор вручную либо искать по одному критерию за раз.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _manufacturer = TextEditingController();
  final TextEditingController _reviewText = TextEditingController();
  final TextEditingController _priceMin = TextEditingController();
  final TextEditingController _priceMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    final query = context.read<CatalogBloc>().state.query;
    _name.text = query.name;
    _manufacturer.text = query.manufacturer;
    _reviewText.text = query.reviewText;
    _priceMin.text = query.priceMin?.toStringAsFixed(0) ?? '';
    _priceMax.text = query.priceMax?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _manufacturer.dispose();
    _reviewText.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    super.dispose();
  }

  void _update(SearchQuery query) =>
      context.read<CatalogBloc>().add(CatalogQueryChanged(query));

  void _clear() {
    _name.clear();
    _manufacturer.clear();
    _reviewText.clear();
    _priceMin.clear();
    _priceMax.clear();
    context.read<CatalogBloc>().add(const CatalogSearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(total: state.items.length),
              const SizedBox(height: 24),
              const _Recommended(),
              _SearchPanel(
                state: state,
                name: _name,
                manufacturer: _manufacturer,
                reviewText: _reviewText,
                priceMin: _priceMin,
                priceMax: _priceMax,
                onQueryChanged: _update,
                onClear: _clear,
              ),
              const SizedBox(height: 20),
              _ResultsBar(state: state),
              const SizedBox(height: 20),
              if (state.results.isEmpty)
                EmptyState(
                  icon: Icons.search_off,
                  title: 'No items match this search',
                  message:
                      'Try a different value, or clear the search to browse '
                      'the whole collection.',
                  action: FilledButton(
                    onPressed: _clear,
                    child: const Text('Clear search'),
                  ),
                )
              else ...[
                _ResultsGrid(state: state),
                if (state.pageCount > 1) ...[
                  const SizedBox(height: 30),
                  _Pager(state: state),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('The collection'),
        const SizedBox(height: 6),
        Text('Catalog', style: context.texts.displayMedium),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            '$total pieces are available in the store. Browse the collection '
            'page by page, or search it by a single criterion — name, type, '
            'size, manufacturer, product date, price range or customer reviews.',
            style: context.texts.bodyLarge,
          ),
        ),
      ],
    );
  }
}

/// Подборка по любимым типам одежды из профиля покупателя.
class _Recommended extends StatelessWidget {
  const _Recommended();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    if (user == null || user.favoriteTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = context
        .watch<CatalogBloc>()
        .state
        .items
        .where((item) => user.favoriteTypes.contains(item.type))
        .take(3)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Panel(
        flat: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Picked for your favourite types',
                        style: context.texts.titleLarge,
                      ),
                      Text(
                        'Based on the favourite item types saved in your profile.',
                        style: context.texts.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Edit favourites'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 640 ? 1 : 3;
                const gap = 10.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: Material(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.go('/catalog/${item.id}'),
                            child: Ink(
                              decoration: BoxDecoration(
                                border: Border.all(color: palette.line),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.texts.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: palette.ink,
                                    ),
                                  ),
                                  Text(
                                    '${item.type.label} · ${item.manufacturer}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.texts.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.state,
    required this.name,
    required this.manufacturer,
    required this.reviewText,
    required this.priceMin,
    required this.priceMax,
    required this.onQueryChanged,
    required this.onClear,
  });

  final CatalogState state;
  final TextEditingController name;
  final TextEditingController manufacturer;
  final TextEditingController reviewText;
  final TextEditingController priceMin;
  final TextEditingController priceMax;
  final ValueChanged<SearchQuery> onQueryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final query = state.query;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search the collection',
                      style: context.texts.titleLarge,
                    ),
                    Text(
                      'Criteria are applied one at a time, as specified by '
                      'the assignment.',
                      style: context.texts.bodySmall,
                    ),
                  ],
                ),
              ),
              if (state.isSearchActive)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: onClear,
                  child: const Text('Clear search'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final criterion in SearchCriterion.values)
                SelectableChip(
                  label: criterion.label,
                  selected: query.criterion == criterion,
                  onTap: () => context.read<CatalogBloc>().add(
                    CatalogCriterionSelected(criterion),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: palette.line, height: 1),
          const SizedBox(height: 18),
          _CriterionFields(
            query: query,
            catalogItems: state.items,
            name: name,
            manufacturer: manufacturer,
            reviewText: reviewText,
            priceMin: priceMin,
            priceMax: priceMax,
            onQueryChanged: onQueryChanged,
          ),
        ],
      ),
    );
  }
}

/// Поля активного критерия. Показывается ровно один набор — задание
/// требует применять критерии по отдельности.
class _CriterionFields extends StatelessWidget {
  const _CriterionFields({
    required this.query,
    required this.catalogItems,
    required this.name,
    required this.manufacturer,
    required this.reviewText,
    required this.priceMin,
    required this.priceMax,
    required this.onQueryChanged,
  });

  final SearchQuery query;
  final List<Item> catalogItems;
  final TextEditingController name;
  final TextEditingController manufacturer;
  final TextEditingController reviewText;
  final TextEditingController priceMin;
  final TextEditingController priceMax;
  final ValueChanged<SearchQuery> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 640;
        final half = narrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;

        return switch (query.criterion) {
          SearchCriterion.name => _Field(
            label: 'Item name',
            hint: 'Matches any part of the item name.',
            child: TextField(
              controller: name,
              decoration: const InputDecoration(
                hintText: 'e.g. trench, hoodie, blazer',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => onQueryChanged(query.copyWith(name: value)),
            ),
          ),

          SearchCriterion.type => SizedBox(
            width: half,
            child: _Field(
              label: 'Item type',
              child: DropdownButtonFormField<ClothingType?>(
                value: query.type,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any type')),
                  for (final type in ClothingType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: (value) => onQueryChanged(
                  value == null
                      ? query.copyWith(clearType: true)
                      : query.copyWith(type: value),
                ),
              ),
            ),
          ),

          SearchCriterion.size => SizedBox(
            width: half,
            child: _Field(
              label: 'Available in size',
              child: DropdownButtonFormField<ClothingSize?>(
                value: query.size,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any size')),
                  for (final size in ClothingSize.values)
                    DropdownMenuItem(value: size, child: Text(size.label)),
                ],
                onChanged: (value) => onQueryChanged(
                  value == null
                      ? query.copyWith(clearSize: true)
                      : query.copyWith(size: value),
                ),
              ),
            ),
          ),

          SearchCriterion.manufacturer => SizedBox(
            width: half,
            child: _Field(
              label: 'Manufacturer',
              child: TextField(
                controller: manufacturer,
                decoration: const InputDecoration(hintText: 'e.g. Greyline'),
                onChanged: (value) =>
                    onQueryChanged(query.copyWith(manufacturer: value)),
              ),
            ),
          ),

          SearchCriterion.productDate => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Released from',
                  child: _DateField(
                    value: query.dateFrom,
                    onChanged: (value) => onQueryChanged(
                      value == null
                          ? query.copyWith(clearDateFrom: true)
                          : query.copyWith(dateFrom: value),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Released until',
                  child: _DateField(
                    value: query.dateTo,
                    onChanged: (value) => onQueryChanged(
                      value == null
                          ? query.copyWith(clearDateTo: true)
                          : query.copyWith(dateTo: value),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SearchCriterion.priceRange => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Minimum price, USD',
                  child: TextField(
                    controller: priceMin,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (value) {
                      final parsed = double.tryParse(value.trim());
                      onQueryChanged(
                        parsed == null
                            ? query.copyWith(clearPriceMin: true)
                            : query.copyWith(priceMin: parsed),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Maximum price, USD',
                  child: TextField(
                    controller: priceMax,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '400'),
                    onChanged: (value) {
                      final parsed = double.tryParse(value.trim());
                      onQueryChanged(
                        parsed == null
                            ? query.copyWith(clearPriceMax: true)
                            : query.copyWith(priceMax: parsed),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          SearchCriterion.reviews => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Review text or author',
                  hint:
                      'Searches the reviews left by customers who ordered '
                      'the item.',
                  child: TextField(
                    controller: reviewText,
                    decoration: const InputDecoration(
                      hintText: 'e.g. warm, durable, Dana',
                    ),
                    onChanged: (value) =>
                        onQueryChanged(query.copyWith(reviewText: value)),
                  ),
                ),
              ),
              SizedBox(
                width: half,
                child: _Field(
                  label: 'Minimum average rating',
                  child: DropdownButtonFormField<double?>(
                    value: query.minRating,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any rating')),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('3 stars and above'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('4 stars and above'),
                      ),
                      DropdownMenuItem(
                        value: 4.5,
                        child: Text('4.5 stars and above'),
                      ),
                    ],
                    onChanged: (value) => onQueryChanged(
                      value == null
                          ? query.copyWith(clearMinRating: true)
                          : query.copyWith(minRating: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        };
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: palette.inkMuted,
          ),
        ),
        const SizedBox(height: 6),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: context.texts.bodySmall),
        ],
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2023),
          firstDate: DateTime(2018),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today, size: 18)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(
          value == null ? 'Any date' : Formatters.isoDate(value!),
          style: context.texts.bodyMedium?.copyWith(
            color: value == null
                ? context.palette.inkMuted
                : context.palette.ink,
          ),
        ),
      ),
    );
  }
}

class _ResultsBar extends StatelessWidget {
  const _ResultsBar({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${state.results.length}',
              style: context.texts.titleLarge?.copyWith(
                fontFamily: null,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'of ${state.items.length} items',
              style: context.texts.bodyMedium,
            ),
            if (state.isSearchActive) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: palette.brandTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _summary(state.query),
                  style: context.texts.bodySmall?.copyWith(
                    color: palette.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<SortOption>(
            value: state.sort,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            items: [
              for (final option in SortOption.values)
                DropdownMenuItem(value: option, child: Text(option.label)),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<CatalogBloc>().add(CatalogSortChanged(value));
              }
            },
          ),
        ),
      ],
    );
  }

  /// Человекочитаемое описание активного критерия.
  static String _summary(SearchQuery query) {
    return switch (query.criterion) {
      SearchCriterion.name => 'Name contains “${query.name.trim()}”',
      SearchCriterion.type => 'Type is ${query.type?.label}',
      SearchCriterion.size => 'Available in size ${query.size?.label}',
      SearchCriterion.manufacturer =>
        'Manufacturer contains “${query.manufacturer.trim()}”',
      SearchCriterion.productDate =>
        'Product date '
            '${query.dateFrom == null ? '…' : Formatters.isoDate(query.dateFrom!)}'
            ' — '
            '${query.dateTo == null ? '…' : Formatters.isoDate(query.dateTo!)}',
      SearchCriterion.priceRange =>
        'Price ${query.priceMin?.toStringAsFixed(0) ?? '…'} — '
            '${query.priceMax?.toStringAsFixed(0) ?? '…'} USD',
      SearchCriterion.reviews => [
        if (query.reviewText.trim().isNotEmpty)
          'reviews mention “${query.reviewText.trim()}”',
        if (query.minRating != null) 'rated ${query.minRating}+ stars',
      ].join(' and '),
    };
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final items = state.visibleResults;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 22,
        mainAxisSpacing: 22,
        mainAxisExtent: 400,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(item: item, stats: state.statsFor(item.id));
      },
    );
  }
}

/// Постраничное «ручное» листание каталога.
class _Pager extends StatelessWidget {
  const _Pager({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bloc = context.read<CatalogBloc>();

    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
            onPressed: state.page <= 1
                ? null
                : () => bloc.add(CatalogPageChanged(state.page - 1)),
            child: const Text('← Previous'),
          ),
          for (final page in state.pages)
            SizedBox(
              width: 38,
              height: 38,
              child: Material(
                color: page == state.page ? palette.brand : palette.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: page == state.page
                        ? palette.brand
                        : palette.lineStrong,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => bloc.add(CatalogPageChanged(page)),
                  child: Center(
                    child: Text(
                      '$page',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: page == state.page
                            ? Colors.white
                            : palette.inkSoft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
            onPressed: state.page >= state.pageCount
                ? null
                : () => bloc.add(CatalogPageChanged(state.page + 1)),
            child: const Text('Next →'),
          ),
        ],
      ),
    );
  }
}
