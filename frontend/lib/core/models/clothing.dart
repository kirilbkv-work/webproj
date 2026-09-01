/// Тип одежды. Используется как атрибут товара, критерий поиска
/// и как «любимый тип» в профиле покупателя.
enum ClothingType {
  sportswear('sportswear', 'Sportswear'),
  workwear('workwear', 'Workwear'),
  formalwear('formalwear', 'Formalwear'),
  casualwear('casualwear', 'Casualwear'),
  outerwear('outerwear', 'Outerwear');

  const ClothingType(this.wireName, this.label);

  /// Значение для сериализации — не зависит от имени константы Dart.
  final String wireName;
  final String label;

  static ClothingType fromWire(String value) => ClothingType.values.firstWhere(
    (type) => type.wireName == value,
    orElse: () => ClothingType.casualwear,
  );
}

/// Размер одежды. Порядок констант задаёт порядок отображения.
enum ClothingSize {
  xs('XS'),
  s('S'),
  m('M'),
  l('L'),
  xl('XL'),
  xxl('XXL');

  const ClothingSize(this.label);

  final String label;

  static ClothingSize fromWire(String value) => ClothingSize.values.firstWhere(
    (size) => size.label == value,
    orElse: () => ClothingSize.m,
  );
}
