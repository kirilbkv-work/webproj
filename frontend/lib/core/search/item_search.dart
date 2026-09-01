import '../models/models.dart';

/// Поиск и сортировка каталога.
///
/// Вынесены в чистые функции: не зависят ни от репозиториев, ни от BLoC,
/// поэтому легко тестируются и переиспользуются.
abstract final class ItemSearch {
  /// Применяет активный критерий и сортировку к набору товаров.
  ///
  /// [statsByItem] нужен для критерия «отзывы» и сортировки по рейтингу.
  static List<Item> apply({
    required List<Item> items,
    required SearchQuery query,
    required SortOption sort,
    required Map<String, ReviewStats> statsByItem,
    required Map<String, List<Review>> reviewsByItem,
  }) {
    final matched = query.isActive
        ? items
              .where(
                (item) => _matches(
                  item,
                  query,
                  statsByItem[item.id] ?? const ReviewStats.empty(),
                  reviewsByItem[item.id] ?? const <Review>[],
                ),
              )
              .toList()
        : List<Item>.of(items);

    return _sorted(matched, sort, statsByItem);
  }

  static bool _matches(
    Item item,
    SearchQuery query,
    ReviewStats stats,
    List<Review> reviews,
  ) {
    return switch (query.criterion) {
      SearchCriterion.name => item.name.toLowerCase().contains(
        query.name.trim().toLowerCase(),
      ),

      SearchCriterion.type => query.type == null || item.type == query.type,

      // Ищем по всем размерам, доступным для резервирования.
      SearchCriterion.size =>
        query.size == null || item.availableSizes.contains(query.size),

      SearchCriterion.manufacturer => item.manufacturer
          .toLowerCase()
          .contains(query.manufacturer.trim().toLowerCase()),

      SearchCriterion.productDate => _inDateRange(
        item.productDate,
        query.dateFrom,
        query.dateTo,
      ),

      SearchCriterion.priceRange => _inPriceRange(
        item.price,
        query.priceMin,
        query.priceMax,
      ),

      SearchCriterion.reviews => _matchesReviews(query, stats, reviews),
    };
  }

  static bool _inDateRange(DateTime date, DateTime? from, DateTime? to) {
    if (from != null && date.isBefore(_startOfDay(from))) return false;
    if (to != null && date.isAfter(_endOfDay(to))) return false;
    return true;
  }

  static bool _inPriceRange(double price, double? min, double? max) {
    if (min != null && price < min) return false;
    if (max != null && price > max) return false;
    return true;
  }

  static bool _matchesReviews(
    SearchQuery query,
    ReviewStats stats,
    List<Review> reviews,
  ) {
    final text = query.reviewText.trim().toLowerCase();
    final textMatch =
        text.isEmpty ||
        reviews.any(
          (review) =>
              review.comment.toLowerCase().contains(text) ||
              review.authorName.toLowerCase().contains(text),
        );
    final ratingMatch =
        query.minRating == null ||
        (stats.hasReviews && stats.average >= query.minRating!);
    return textMatch && ratingMatch;
  }

  static List<Item> _sorted(
    List<Item> items,
    SortOption sort,
    Map<String, ReviewStats> statsByItem,
  ) {
    double ratingOf(Item item) =>
        (statsByItem[item.id] ?? const ReviewStats.empty()).average;

    final sorted = List<Item>.of(items);
    switch (sort) {
      case SortOption.relevance:
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.productDate.compareTo(a.productDate));
      case SortOption.ratingDesc:
        sorted.sort((a, b) => ratingOf(b).compareTo(ratingOf(a)));
    }
    return sorted;
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);
}
