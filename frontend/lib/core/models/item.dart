import 'package:equatable/equatable.dart';

import 'clothing.dart';

/// Товар каталога.
///
/// Набор атрибутов соответствует заданию: название, тип, размер,
/// производитель, дата выпуска и цена. Отзывы хранятся отдельно
/// и связываются с товаром по [id].
class Item extends Equatable {
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.size,
    required this.availableSizes,
    required this.manufacturer,
    required this.productDate,
    required this.price,
    required this.material,
    required this.colorway,
    required this.coverFrom,
    required this.coverTo,
  });

  final String id;
  final String name;
  final String description;
  final ClothingType type;

  /// Размер, под которым товар представлен в каталоге.
  final ClothingSize size;

  /// Размеры, доступные при резервировании. Всегда содержит [size].
  final List<ClothingSize> availableSizes;

  final String manufacturer;
  final DateTime productDate;
  final double price;
  final String material;
  final String colorway;

  /// Пара цветов (ARGB) для генеративной обложки товара.
  final int coverFrom;
  final int coverTo;

  Item copyWith({
    String? name,
    String? description,
    ClothingType? type,
    ClothingSize? size,
    List<ClothingSize>? availableSizes,
    String? manufacturer,
    DateTime? productDate,
    double? price,
    String? material,
    String? colorway,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      size: size ?? this.size,
      availableSizes: availableSizes ?? this.availableSizes,
      manufacturer: manufacturer ?? this.manufacturer,
      productDate: productDate ?? this.productDate,
      price: price ?? this.price,
      material: material ?? this.material,
      colorway: colorway ?? this.colorway,
      coverFrom: coverFrom,
      coverTo: coverTo,
    );
  }

  /// Монограмма для обложки: первые буквы двух первых слов названия.
  String get monogram => name
      .split(' ')
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.wireName,
    'size': size.label,
    'availableSizes': availableSizes.map((size) => size.label).toList(),
    'manufacturer': manufacturer,
    'productDate': productDate.toIso8601String(),
    'price': price,
    'material': material,
    'colorway': colorway,
    'coverFrom': coverFrom,
    'coverTo': coverTo,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    type: ClothingType.fromWire(json['type'] as String),
    size: ClothingSize.fromWire(json['size'] as String),
    availableSizes: (json['availableSizes'] as List<dynamic>)
        .map((value) => ClothingSize.fromWire(value as String))
        .toList(),
    manufacturer: json['manufacturer'] as String,
    productDate: DateTime.parse(json['productDate'] as String),
    price: (json['price'] as num).toDouble(),
    material: json['material'] as String,
    colorway: json['colorway'] as String,
    coverFrom: json['coverFrom'] as int,
    coverTo: json['coverTo'] as int,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    size,
    availableSizes,
    manufacturer,
    productDate,
    price,
    material,
    colorway,
    coverFrom,
    coverTo,
  ];
}
