part of 'item_details_bloc.dart';

class ItemDetailsState extends Equatable {
  const ItemDetailsState({
    this.item,
    this.reviews = const [],
    this.stats = const ReviewStats.empty(),
    this.related = const [],
    this.myOrders = const [],
  });

  /// null when the id is not in the catalog
  final Item? item;

  /// reviews from customers who ordered this item
  final List<Review> reviews;
  final ReviewStats stats;

  /// other items of the same type
  final List<Item> related;

  /// current customer's orders for this item
  final List<Order> myOrders;

  bool get exists => item != null;

  /// rating distribution from 5 to 1
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
