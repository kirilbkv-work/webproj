import 'package:equatable/equatable.dart';

/// Отзыв покупателя, который заказывал товар.
///
/// Создаётся, когда пользователь оценивает свой заказ в статусе `arrived`.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.itemId,
    required this.authorId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String itemId;
  final String authorId;
  final String authorName;

  /// Оценка от 1 до 5.
  final int rating;
  final String comment;
  final DateTime createdAt;

  /// Заказ, из которого получен отзыв.
  final String? orderId;

  Review copyWith({int? rating, String? comment}) => Review(
    id: id,
    itemId: itemId,
    authorId: authorId,
    authorName: authorName,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    createdAt: createdAt,
    orderId: orderId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'authorId': authorId,
    'authorName': authorName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'orderId': orderId,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    itemId: json['itemId'] as String,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    orderId: json['orderId'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    itemId,
    authorId,
    authorName,
    rating,
    comment,
    createdAt,
    orderId,
  ];
}

/// Количество отзывов и средняя оценка по одному товару.
class ReviewStats extends Equatable {
  const ReviewStats({required this.count, required this.average});

  const ReviewStats.empty() : count = 0, average = 0;

  final int count;
  final double average;

  bool get hasReviews => count > 0;

  @override
  List<Object?> get props => [count, average];
}
