import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';

class ItemService {
  final SupabaseClient _client = Supabase.instance.client;

  // TAMBAH / CREATE
  Future<ItemModel> createItem({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    final data = await _client
        .from('items')
        .insert({
          'user_id': userId,
          'title': title,
          'description': description,
          'image_url': imageUrl,
          'category': category,
        })
        .select()
        .single();

    return ItemModel.fromMap(data);
  }

  // AMBIL SEMUA (per user) / READ ALL (by user)
  Future<List<ItemModel>> getItems(String userId) async {
    final data = await _client
        .from('items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((map) => ItemModel.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // AMBIL SATU / READ ONE
  Future<ItemModel> getItemById(String itemId) async {
    final data = await _client
        .from('items')
        .select()
        .eq('id', itemId)
        .single();

    return ItemModel.fromMap(data);
  }

  // PERBARUI / UPDATE
  Future<ItemModel> updateItem({
    required String itemId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    final data = await _client
        .from('items')
        .update({
          'title': title,
          'description': description,
          'image_url': imageUrl,
          'category': category,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', itemId)
        .select()
        .single();

    return ItemModel.fromMap(data);
  }

  // HAPUS / DELETE
  Future<void> deleteItem(String itemId) async {
    await _client.from('items').delete().eq('id', itemId);
  }

  // CARI / SEARCH
  Future<List<ItemModel>> searchItems(String userId, String query) async {
    final data = await _client
        .from('items')
        .select()
        .eq('user_id', userId)
        .ilike('title', '%$query%')
        .order('created_at', ascending: false);

    return (data as List)
        .map((map) => ItemModel.fromMap(map as Map<String, dynamic>))
        .toList();
  }
}
