import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../core/search/item_search.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/review_repository.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

/// catalog and search; watches items and reviews
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({
    required CatalogRepository catalog,
    required ReviewRepository reviews,
  }) : _catalog = catalog,
       _reviews = reviews,
       super(_build(catalog, reviews, const CatalogState())) {
    on<_CatalogDataChanged>(_onDataChanged);
    on<CatalogCriterionSelected>(_onCriterionSelected);
    on<CatalogQueryChanged>(_onQueryChanged);
    on<CatalogSortChanged>(_onSortChanged);
    on<CatalogPageChanged>(_onPageChanged);
    on<CatalogSearchCleared>(_onSearchCleared);

    _catalogSubscription = _catalog.stream.listen(
      (_) => add(const _CatalogDataChanged()),
    );
    _reviewsSubscription = _reviews.stream.listen(
      (_) => add(const _CatalogDataChanged()),
    );
  }

  final CatalogRepository _catalog;
  final ReviewRepository _reviews;
  late final StreamSubscription<List<Item>> _catalogSubscription;
  late final StreamSubscription<List<Review>> _reviewsSubscription;

  void _onDataChanged(_CatalogDataChanged event, Emitter<CatalogState> emit) {
    emit(_recompute(state));
  }

  void _onCriterionSelected(
    CatalogCriterionSelected event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      _recompute(
        state.copyWith(
          query: state.query.copyWith(criterion: event.criterion),
          page: 1,
        ),
      ),
    );
  }

  void _onQueryChanged(CatalogQueryChanged event, Emitter<CatalogState> emit) {
    emit(_recompute(state.copyWith(query: event.query, page: 1)));
  }

  void _onSortChanged(CatalogSortChanged event, Emitter<CatalogState> emit) {
    emit(_recompute(state.copyWith(sort: event.sort, page: 1)));
  }

  void _onPageChanged(CatalogPageChanged event, Emitter<CatalogState> emit) {
    emit(state.copyWith(page: event.page.clamp(1, state.pageCount)));
  }

  void _onSearchCleared(
    CatalogSearchCleared event,
    Emitter<CatalogState> emit,
  ) {
    emit(_recompute(state.copyWith(query: state.query.cleared(), page: 1)));
  }

  CatalogState _recompute(CatalogState base) => _build(_catalog, _reviews, base);

  /// recomputes results from the repositories and the query
  static CatalogState _build(
    CatalogRepository catalog,
    ReviewRepository reviewRepository,
    CatalogState base,
  ) {
    final items = catalog.items;
    final reviews = reviewRepository.reviews;
    final stats = ReviewRepository.statsByItem(reviews);
    final grouped = ReviewRepository.groupByItem(reviews);

    final results = ItemSearch.apply(
      items: items,
      query: base.query,
      sort: base.sort,
      statsByItem: stats,
      reviewsByItem: grouped,
    );

    final pageCount = results.isEmpty
        ? 1
        : (results.length / kCatalogPageSize).ceil();

    return base.copyWith(
      items: items,
      results: results,
      statsByItem: stats,
      page: base.page.clamp(1, pageCount),
    );
  }

  @override
  Future<void> close() {
    _catalogSubscription.cancel();
    _reviewsSubscription.cancel();
    return super.close();
  }
}
