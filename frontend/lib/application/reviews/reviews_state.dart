part of 'reviews_bloc.dart';

/// Отзыв вместе с товаром, к которому он относится.
class ReviewRow extends Equatable {
  const ReviewRow({required this.review, required this.item});

  final Review review;
  final Item? item;

  @override
  List<Object?> get props => [review, item];
}

class ReviewsState extends Equatable {
  const ReviewsState({
    this.rows = const [],
    this.items = const [],
    this.totalCount = 0,
    this.averageRating = 0,
    this.itemFilter,
    this.ratingFilter,
  });

  /// Отзывы после применения фильтров, свежие сверху.
  final List<ReviewRow> rows;

  /// Все товары — для выпадающего списка фильтра.
  final List<Item> items;

  /// Общее количество отзывов в магазине (без фильтров).
  final int totalCount;
  final double averageRating;

  final String? itemFilter;
  final int? ratingFilter;

  bool get hasFilters => itemFilter != null || ratingFilter != null;

  ReviewsState copyWith({
    List<ReviewRow>? rows,
    List<Item>? items,
    int? totalCount,
    double? averageRating,
    String? itemFilter,
    bool clearItemFilter = false,
    int? ratingFilter,
    bool clearRatingFilter = false,
  }) {
    return ReviewsState(
      rows: rows ?? this.rows,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      averageRating: averageRating ?? this.averageRating,
      itemFilter: clearItemFilter ? null : (itemFilter ?? this.itemFilter),
      ratingFilter: clearRatingFilter
          ? null
          : (ratingFilter ?? this.ratingFilter),
    );
  }

  @override
  List<Object?> get props => [
    rows,
    items,
    totalCount,
    averageRating,
    itemFilter,
    ratingFilter,
  ];
}
