part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => const [];
}

/// Выбор критерия поиска. Критерии применяются по одному за раз.
class CatalogCriterionSelected extends CatalogEvent {
  const CatalogCriterionSelected(this.criterion);

  final SearchCriterion criterion;

  @override
  List<Object?> get props => [criterion];
}

/// Изменение значения активного критерия.
class CatalogQueryChanged extends CatalogEvent {
  const CatalogQueryChanged(this.query);

  final SearchQuery query;

  @override
  List<Object?> get props => [query];
}

class CatalogSortChanged extends CatalogEvent {
  const CatalogSortChanged(this.sort);

  final SortOption sort;

  @override
  List<Object?> get props => [sort];
}

class CatalogPageChanged extends CatalogEvent {
  const CatalogPageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class CatalogSearchCleared extends CatalogEvent {
  const CatalogSearchCleared();
}

/// Внутреннее событие: изменился каталог или набор отзывов.
class _CatalogDataChanged extends CatalogEvent {
  const _CatalogDataChanged();
}
