import 'package:equatable/equatable.dart';

import 'clothing.dart';

/// order status and the actions allowed in it
enum OrderStatus {
  inProgress('in progress', 'In progress'),
  arrived('arrived', 'Arrived'),
  canceled('canceled', 'Canceled');

  const OrderStatus(this.wireName, this.label);

  final String wireName;
  final String label;

  /// only arrived orders can be deleted
  bool get canDelete => this == OrderStatus.arrived;

  /// details stay editable until delivery
  bool get canEdit =>
      this == OrderStatus.inProgress || this == OrderStatus.canceled;

  /// only arrived orders can be rated
  bool get canRate => this == OrderStatus.arrived;

  static OrderStatus fromWire(String value) => OrderStatus.values.firstWhere(
    (status) => status.wireName == value,
    orElse: () => OrderStatus.inProgress,
  );
}

/// a reservation in the order cart; item data is read from the catalog
class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.size,
    required this.quantity,
    required this.status,
    required this.reservedAt,
    required this.deliveryAddress,
    required this.note,
    this.rating,
    this.reviewId,
  });

  final String id;
  final String userId;
  final String itemId;
  final ClothingSize size;
  final int quantity;
  final OrderStatus status;
  final DateTime reservedAt;
  final String deliveryAddress;
  final String note;

  /// 1 to 5, arrived orders only
  final int? rating;

  /// review created from this rating
  final String? reviewId;

  Order copyWith({
    ClothingSize? size,
    int? quantity,
    OrderStatus? status,
    String? deliveryAddress,
    String? note,
    int? rating,
    String? reviewId,
  }) {
    return Order(
      id: id,
      userId: userId,
      itemId: itemId,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      reservedAt: reservedAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      reviewId: reviewId ?? this.reviewId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemId': itemId,
    'size': size.label,
    'quantity': quantity,
    'status': status.wireName,
    'reservedAt': reservedAt.toIso8601String(),
    'deliveryAddress': deliveryAddress,
    'note': note,
    'rating': rating,
    'reviewId': reviewId,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['userId'] as String,
    itemId: json['itemId'] as String,
    size: ClothingSize.fromWire(json['size'] as String),
    quantity: json['quantity'] as int,
    status: OrderStatus.fromWire(json['status'] as String),
    reservedAt: DateTime.parse(json['reservedAt'] as String),
    deliveryAddress: json['deliveryAddress'] as String,
    note: json['note'] as String,
    rating: json['rating'] as int?,
    reviewId: json['reviewId'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    size,
    quantity,
    status,
    reservedAt,
    deliveryAddress,
    note,
    rating,
    reviewId,
  ];
}

/// order fields the customer can set
class OrderDraft extends Equatable {
  const OrderDraft({
    required this.size,
    required this.quantity,
    required this.deliveryAddress,
    required this.note,
  });

  final ClothingSize size;
  final int quantity;
  final String deliveryAddress;
  final String note;

  OrderDraft copyWith({
    ClothingSize? size,
    int? quantity,
    String? deliveryAddress,
    String? note,
  }) => OrderDraft(
    size: size ?? this.size,
    quantity: quantity ?? this.quantity,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    note: note ?? this.note,
  );

  /// returns an error text or null
  String? validate() {
    if (quantity < 1 || quantity > 10) {
      return 'Quantity must be a whole number between 1 and 10.';
    }
    if (deliveryAddress.trim().length < 5) {
      return 'Please provide a delivery address.';
    }
    return null;
  }

  @override
  List<Object?> get props => [size, quantity, deliveryAddress, note];
}
