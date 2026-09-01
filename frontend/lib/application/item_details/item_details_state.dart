part of 'item_details_bloc.dart';

class ItemDetailsState extends Equatable {
  const ItemDetailsState({
    this.item,
    this.reviews = const [],
    this.stats = const ReviewStats.empty(),
    this.related = const [],
    this.myOrders = const [],
  });

  /// `null`, если товара с таким идентификатором нет в каталоге.
  final Item? item;

  /// Отзывы покупателей, которые заказывали этот товар.
  final List<Review> reviews;
  final ReviewStats stats;

  /// Другие товары того же типа.
  final List<Item> related;

  /// Заказы текущего покупателя по этому товару.
  final List<Order> myOrders;

  bool get exists => item != null;

  /// Распределение оценок 5→1 для гистограммы отзывов.
  List<({int stars, int count, double fraction})> get ratingBreakdown {
    return [
      for (final stars in const [5, 4, 3, 2, 1])
        (
          stars: stars,
          count: reviews.where((review) => review.rating == stars).length,
          fraction: reviews.isEmpty
              ? 0.0
              : reviews.where((review) => review.rating == stars).length /
                    reviews.length,
        ),
    ];
  }

  ItemDetailsState copyWith({
    Item? item,
    bool clearItem = false,
    List<Review>? reviews,
    ReviewStats? stats,
    List<Item>? related,
    List<Order>? myOrders,
  }) {
    return ItemDetailsState(
      item: clearItem ? null : (item ?? this.item),
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      related: related ?? this.related,
      myOrders: myOrders ?? this.myOrders,
    );
  }

  @override
  List<Object?> get props => [item, reviews, stats, related, myOrders];
}
