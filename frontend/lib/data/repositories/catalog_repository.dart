import '../../core/models/models.dart';
import '../../core/utils/id_generator.dart';
import '../seed/seed_data.dart';
import '../services/storage_service.dart';
import '../services/value_store.dart';

/// simulated catalog backend: read, add, edit, delete
class CatalogRepository {
  CatalogRepository(this._storage)
    : _store = ValueStore<List<Item>>(
        _storage.readList('items', Item.fromJson, SeedData.items),
      );

  static const String _key = 'items';

  final StorageService _storage;
  final ValueStore<List<Item>> _store;

  List<Item> get items => List.unmodifiable(_store.value);

  Stream<List<Item>> get stream => _store.stream;

  Item? byId(String id) {
    for (final item in _store.value) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// other items of the same type
  List<Item> relatedTo(String id, {int limit = 3}) {
    final source = byId(id);
    if (source == null) return const [];
    return _store.value
        .where((item) => item.id != id && item.type == source.type)
        .take(limit)
        .toList();
  }

  List<ClothingType> get types {
    final present = _store.value.map((item) => item.type).toSet();
    return ClothingType.values.where(present.contains).toList();
  }

  List<ClothingSize> get sizes {
    final present = _store.value.expand((item) => item.availableSizes).toSet();
    return ClothingSize.values.where(present.contains).toList();
  }

  List<String> get manufacturers {
    final names = _store.value.map((item) => item.manufacturer).toSet().toList()
      ..sort();
    return names;
  }

  ({double min, double max}) get priceBounds {
    if (_store.value.isEmpty) return (min: 0, max: 0);
    final prices = _store.value.map((item) => item.price);
    return (
      min: prices.reduce((a, b) => a < b ? a : b).floorToDouble(),
      max: prices.reduce((a, b) => a > b ? a : b).ceilToDouble(),
    );
  }

  ({DateTime? min, DateTime? max}) get dateBounds {
    if (_store.value.isEmpty) return (min: null, max: null);
    final dates = _store.value.map((item) => item.productDate).toList()..sort();
    return (min: dates.first, max: dates.last);
  }

  Item add(Item item) {
    final created = Item(
      id: IdGenerator.create('itm'),
      name: item.name,
      description: item.description,
      type: item.type,
      size: item.size,
      availableSizes: item.availableSizes,
      manufacturer: item.manufacturer,
      productDate: item.productDate,
      price: item.price,
      material: item.material,
      colorway: item.colorway,
      coverFrom: item.coverFrom,
      coverTo: item.coverTo,
    );
    _commit([created, ..._store.value]);
    return created;
  }

  void update(Item item) {
    _commit([
      for (final candidate in _store.value)
        if (candidate.id == item.id) item else candidate,
    ]);
  }

  void remove(String id) {
    _commit(_store.value.where((item) => item.id != id).toList());
  }

  void reset() => _commit(SeedData.items);

  void _commit(List<Item> next) {
    _storage.writeList(_key, next, (item) => item.toJson());
    _store.emit(next);
  }

  Future<void> dispose() => _store.dispose();
}
