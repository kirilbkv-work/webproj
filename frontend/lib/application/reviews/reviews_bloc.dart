import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/models.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/review_repository.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

/// all customer reviews; open to guests
class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({
    required ReviewRepository reviews,
    required CatalogRepository catalog,
  }) : _reviews = reviews,
       _catalog = catalog,
       super(_build(reviews, catalog, const ReviewsState())) {
    on<_ReviewsDataChanged>(_onDataChanged);
    on<ReviewsItemFilterChanged>(_onItemFilterChanged);
    on<ReviewsRatingFilterToggled>(_onRatingFilterToggled);
    on<ReviewsFiltersCleared>(_onFiltersCleared);

    _reviewsSubscription = _reviews.stream.listen(
      (_) => add(const _ReviewsDataChanged()),
    );
    _catalogSubscription = _catalog.stream.listen(
      (_) => add(const _ReviewsDataChanged()),
    );
  }

  final ReviewRepository _reviews;
  final CatalogRepository _catalog;
  late final StreamSubscription<List<Review>> _reviewsSubscription;
  late final StreamSubscription<List<Item>> _catalogSubscription;

  void _onDataChanged(_ReviewsDataChanged event, Emitter<ReviewsState> emit) {
    emit(_build(_reviews, _catalog, state));
  }

  void _onItemFilterChanged(
    ReviewsItemFilterChanged event,
    Emitter<ReviewsState> emit,
  ) {
    final next = event.itemId == null
        ? state.copyWith(clearItemFilter: true)
        : state.copyWith(itemFilter: event.itemId);
    emit(_build(_reviews, _catalog, next));
  }

  void _onRatingFilterToggled(
    ReviewsRatingFilterToggled event,
    Emitter<ReviewsState> emit,
  ) {
    final next = state.ratingFilter == event.rating
        ? state.copyWith(clearRatingFilter: true)
        : state.copyWith(ratingFilter: event.rating);
    emit(_build(_reviews, _catalog, next));
  }

  void _onFiltersCleared(
    ReviewsFiltersCleared event,
    Emitter<ReviewsState> emit,
  ) {
    emit(
      _build(
        _reviews,
        _catalog,
        state.copyWith(clearItemFilter: true, clearRatingFilter: true),
      ),
    );
  }

  static ReviewsState _build(
    ReviewRepository reviewRepository,
    CatalogRepository catalog,
    ReviewsState base,
  ) {
    final all = reviewRepository.reviews;
    final filtered = all
        .where(
          (review) =>
              base.itemFilter == null || review.itemId == base.itemFilter,
        )
        .where(
          (review) =>
              base.ratingFilter == null || review.rating == base.ratingFilter,
        )
        .map((review) => ReviewRow(review: review, item: catalog.byId(review.itemId)))
        .toList();

    final average = all.isEmpty
        ? 0.0
        : all.map((review) => review.rating).reduce((a, b) => a + b) /
              all.length;

    return base.copyWith(
      rows: filtered,
      items: catalog.items,
      totalCount: all.length,
      averageRating: average,
    );
  }

  @override
  Future<void> close() {
    _reviewsSubscription.cancel();
    _catalogSubscription.cancel();
    return super.close();
  }
}
