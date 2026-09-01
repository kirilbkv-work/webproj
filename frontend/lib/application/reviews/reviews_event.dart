part of 'reviews_bloc.dart';

sealed class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => const [];
}

class ReviewsItemFilterChanged extends ReviewsEvent {
  const ReviewsItemFilterChanged(this.itemId);

  final String? itemId;

  @override
  List<Object?> get props => [itemId];
}

class ReviewsRatingFilterToggled extends ReviewsEvent {
  const ReviewsRatingFilterToggled(this.rating);

  final int rating;

  @override
  List<Object?> get props => [rating];
}

class ReviewsFiltersCleared extends ReviewsEvent {
  const ReviewsFiltersCleared();
}

class _ReviewsDataChanged extends ReviewsEvent {
  const _ReviewsDataChanged();
}
