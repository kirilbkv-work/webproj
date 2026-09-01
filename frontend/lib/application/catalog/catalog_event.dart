part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => const [];
}

/// one criterion is active at a time
class CatalogCriterionSelected extends CatalogEvent {
  const CatalogCriterionSelected(this.criterion);

  final SearchCriterion criterion;

  @override
  List<Object?> get props => [criterion];
}

/// value of the active criterion changed
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

/// internal: catalog or reviews changed
class _CatalogDataChanged extends CatalogEvent {
  const _CatalogDataChanged();
}
