import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

enum ItemStatus { idle, loading, success, error }

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  // ─── State / State ───────────────────────────────────────────
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  ItemStatus _status = ItemStatus.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // ─── Getters / Getters ───────────────────────────────────────
  List<ItemModel> get items => _filteredItems.isEmpty && _searchQuery.isEmpty
      ? _items
      : _filteredItems;
  ItemStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == ItemStatus.loading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get itemCount => _items.length;

  // ─── AMBIL SEMUA / FETCH ALL ─────────────────────────────────
  Future<void> fetchItems(String userId) async {
    _setLoading();
    try {
      _items = await _itemService.getItems(userId);
      _applyFilter();
      _setSuccess();
    } catch (e) {
      _setError('Gagal memuat data. Coba lagi.');
    }
  }

  // ─── TAMBAH / CREATE ─────────────────────────────────────────
  Future<bool> createItem({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    _setLoading();
    try {
      final newItem = await _itemService.createItem(
        userId: userId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: category,
      );
      // Perbarui daftar lokal / Update local list
      _items.insert(0, newItem);
      _applyFilter();
      _setSuccess();
      return true;
    } catch (e) {
      _setError('Gagal menambahkan item.');
      return false;
    }
  }

  // ─── PERBARUI / UPDATE ───────────────────────────────────────
  Future<bool> updateItem({
    required String itemId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    _setLoading();
    try {
      final updatedItem = await _itemService.updateItem(
        itemId: itemId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: category,
      );
      // Perbarui daftar lokal / Update local list
      final index = _items.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _items[index] = updatedItem;
      }
      _applyFilter();
      _setSuccess();
      return true;
    } catch (e) {
      _setError('Gagal mengupdate item.');
      return false;
    }
  }

  // ─── HAPUS / DELETE ──────────────────────────────────────────
  Future<bool> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      // Hapus dari daftar lokal / Remove from local list
      _items.removeWhere((i) => i.id == itemId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal menghapus item.');
      return false;
    }
  }

  // ─── CARI / SEARCH ───────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // ─── FILTER KATEGORI / FILTER CATEGORY ───────────────────────
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var result = _items;

    // Filter berdasarkan kategori / Filter by category
    if (_selectedCategory != 'All') {
      result = result.where((i) => i.category == _selectedCategory).toList();
    }

    // Filter berdasarkan pencarian / Filter by search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((i) =>
              i.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    _filteredItems = result;
  }

  // ─── BERSIHKAN / CLEAR ───────────────────────────────────────
  void clearItems() {
    _items = [];
    _filteredItems = [];
    _searchQuery = '';
    _selectedCategory = 'All';
    _status = ItemStatus.idle;
    notifyListeners();
  }

  // ─── Helpers / Helpers ───────────────────────────────────────
  void _setLoading() {
    _status = ItemStatus.loading;
    notifyListeners();
  }

  void _setSuccess() {
    _status = ItemStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ItemStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
