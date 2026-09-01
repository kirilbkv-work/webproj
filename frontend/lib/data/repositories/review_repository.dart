import '../../core/models/models.dart';
import '../../core/utils/id_generator.dart';
import '../seed/seed_data.dart';
import '../services/storage_service.dart';
import '../services/value_store.dart';

/// simulated review backend
class ReviewRepository {
  ReviewRepository(this._storage)
    : _store = ValueStore<List<Review>>(
        _sortedByDate(
          _storage.readList('reviews', Review.fromJson, SeedData.reviews),
        ),
      );

  static const String _key = 'reviews';

  final StorageService _storage;
  final ValueStore<List<Review>> _store;

  /// newest first
  List<Review> get reviews => List.unmodifiable(_store.value);

  Stream<List<Review>> get stream => _store.stream;

  Review? byId(String id) {
    for (final review in _store.value) {
      if (review.id == id) return review;
    }
    return null;
  }

  List<Review> forItem(String itemId) =>
      _store.value.where((review) => review.itemId == itemId).toList();

  List<Review> byAuthor(String authorId) =>
      _store.value.where((review) => review.authorId == authorId).toList();

  /// groups reviews by item
  static Map<String, List<Review>> groupByItem(List<Review> reviews) {
    final map = <String, List<Review>>{};
    for (final review in reviews) {
      map.putIfAbsent(review.itemId, () => <Review>[]).add(review);
    }
    return map;
  }

  /// count and average per item
  static Map<String, ReviewStats> statsByItem(List<Review> reviews) {
    final totals = <String, (int count, int sum)>{};
    for (final review in reviews) {
      final current = totals[review.itemId] ?? (0, 0);
      totals[review.itemId] = (current.$1 + 1, current.$2 + review.rating);
    }
    return {
      for (final entry in totals.entries)
        entry.key: ReviewStats(
          count: entry.value.$1,
          average: entry.value.$2 / entry.value.$1,
        ),
    };
  }

  Review add({
    required String itemId,
    required String authorId,
    required String authorName,
    required int rating,
    required String comment,
    String? orderId,
  }) {
    final review = Review(
      id: IdGenerator.create('rev'),
      itemId: itemId,
      authorId: authorId,
      authorName: authorName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      orderId: orderId,
    );
    _commit([review, ..._store.value]);
    return review;
  }

  void update(String id, {required int rating, required String comment}) {
    _commit([
      for (final review in _store.value)
        if (review.id == id)
          review.copyWith(rating: rating, comment: comment)
        else
          review,
    ]);
  }

  void remove(String id) {
    _commit(_store.value.where((review) => review.id != id).toList());
  }

  void reset() => _commit(SeedData.reviews);

  void _commit(List<Review> next) {
    final sorted = _sortedByDate(next);
    _storage.writeList(_key, sorted, (review) => review.toJson());
    _store.emit(sorted);
  }

  static List<Review> _sortedByDate(List<Review> reviews) =>
      List<Review>.of(reviews)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> dispose() => _store.dispose();
}
