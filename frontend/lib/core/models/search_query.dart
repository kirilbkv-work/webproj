import 'package:equatable/equatable.dart';

import 'clothing.dart';

/// Критерии поиска. Задание требует применять их **по отдельности**,
/// поэтому запрос всегда содержит ровно один активный критерий.
enum SearchCriterion {
  name('Name'),
  type('Type'),
  size('Size'),
  manufacturer('Manufacturer'),
  productDate('Product date'),
  priceRange('Price range'),
  reviews('User reviews');

  const SearchCriterion(this.label);

  final String label;
}

/// Порядок сортировки выдачи.
enum SortOption {
  relevance('Default order'),
  priceAsc('Price: low to high'),
  priceDesc('Price: high to low'),
  dateDesc('Newest first'),
  ratingDesc('Best rated');

  const SortOption(this.label);

  final String label;
}

/// Значения всех критериев поиска. Активным считается только тот,
/// который выбран в [criterion].
class SearchQuery extends Equatable {
  const SearchQuery({
    this.criterion = SearchCriterion.name,
    this.name = '',
    this.type,
    this.size,
    this.manufacturer = '',
    this.dateFrom,
    this.dateTo,
    this.priceMin,
    this.priceMax,
    this.reviewText = '',
    this.minRating,
  });

  final SearchCriterion criterion;
  final String name;
  final ClothingType? type;
  final ClothingSize? size;
  final String manufacturer;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? priceMin;
  final double? priceMax;
  final String reviewText;
  final double? minRating;

  /// Заполнено ли значение выбранного критерия.
  bool get isActive => switch (criterion) {
    SearchCriterion.name => name.trim().isNotEmpty,
    SearchCriterion.type => type != null,
    SearchCriterion.size => size != null,
    SearchCriterion.manufacturer => manufacturer.trim().isNotEmpty,
    SearchCriterion.productDate => dateFrom != null || dateTo != null,
    SearchCriterion.priceRange => priceMin != null || priceMax != null,
    SearchCriterion.reviews => reviewText.trim().isNotEmpty || minRating != null,
  };

  SearchQuery copyWith({
    SearchCriterion? criterion,
    String? name,
    ClothingType? type,
    bool clearType = false,
    ClothingSize? size,
    bool clearSize = false,
    String? manufacturer,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    double? priceMin,
    bool clearPriceMin = false,
    double? priceMax,
    bool clearPriceMax = false,
    String? reviewText,
    double? minRating,
    bool clearMinRating = false,
  }) {
    return SearchQuery(
      criterion: criterion ?? this.criterion,
      name: name ?? this.name,
      type: clearType ? null : (type ?? this.type),
      size: clearSize ? null : (size ?? this.size),
      manufacturer: manufacturer ?? this.manufacturer,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
      reviewText: reviewText ?? this.reviewText,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
    );
  }

  /// Сбрасывает все значения, сохраняя выбранный критерий.
  SearchQuery cleared() => SearchQuery(criterion: criterion);

  @override
  List<Object?> get props => [
    criterion,
    name,
    type,
    size,
    manufacturer,
    dateFrom,
    dateTo,
    priceMin,
    priceMax,
    reviewText,
    minRating,
  ];
}
