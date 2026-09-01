part of 'catalog_bloc.dart';

/// items per catalog page
const int kCatalogPageSize = 8;

class CatalogState extends Equatable {
  const CatalogState({
    this.items = const [],
    this.results = const [],
    this.statsByItem = const {},
    this.query = const SearchQuery(),
    this.sort = SortOption.relevance,
    this.page = 1,
  });

  /// the whole predefined set
  final List<Item> items;

  /// items after search and sorting
  final List<Item> results;

  final Map<String, ReviewStats> statsByItem;
  final SearchQuery query;
  final SortOption sort;
  final int page;

  bool get isSearchActive => query.isActive;

  int get pageCount =>
      results.isEmpty ? 1 : (results.length / kCatalogPageSize).ceil();

  /// current page of results
  List<Item> get visibleResults {
    final safePage = page.clamp(1, pageCount);
    final start = (safePage - 1) * kCatalogPageSize;
    final end = (start + kCatalogPageSize).clamp(0, results.length);
    if (start >= results.length) return const [];
    return results.sublist(start, end);
  }

  List<int> get pages => List<int>.generate(pageCount, (index) => index + 1);

  ReviewStats statsFor(String itemId) =>
      statsByItem[itemId] ?? const ReviewStats.empty();

  CatalogState copyWith({
    List<Item>? items,
    List<Item>? results,
    Map<String, ReviewStats>? statsByItem,
    SearchQuery? query,
    SortOption? sort,
    int? page,
  }) {
    return CatalogState(
      items: items ?? this.items,
      results: results ?? this.results,
      statsByItem: statsByItem ?? this.statsByItem,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [items, results, statsByItem, query, sort, page];
}
