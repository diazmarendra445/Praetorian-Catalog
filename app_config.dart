import 'package:flutter/material.dart';

class AppConfig {
  
  //  GANTI DENGAN SUPABASE URL & ANON KEY /
  //  REPLACE WITH SUPABASE URL & ANON KEY
  
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';

  // Info Aplikasi / App Info
  static const String appName = 'My Catalog';

  // Warna Tema / Theme Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEDE9FF);
  static const Color secondaryColor = Color(0xFF3F3D56);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color backgroundColor = Color(0xFFF5F4FF);
  static const Color successColor = Color(0xFF43A047);
  static const Color errorColor = Color(0xFFE53935);

  // Daftar Kategori / Categories
  static const List<String> categories = [
    'General',
    'Electronics',
    'Fashion',
    'Food & Drink',
    'Books',
    'Sports',
    'Home & Garden',
    'Other',
  ];

  // Ikon per Kategori / Category icons
  static const Map<String, IconData> categoryIcons = {
    'General': Icons.category,
    'Electronics': Icons.devices,
    'Fashion': Icons.checkroom,
    'Food & Drink': Icons.restaurant,
    'Books': Icons.menu_book,
    'Sports': Icons.sports_soccer,
    'Home & Garden': Icons.home,
    'Other': Icons.more_horiz,
  };

  // Warna per Kategori / Category colors
  static const Map<String, Color> categoryColors = {
    'General': Color(0xFF6C63FF),
    'Electronics': Color(0xFF2196F3),
    'Fashion': Color(0xFFE91E63),
    'Food & Drink': Color(0xFFFF9800),
    'Books': Color(0xFF4CAF50),
    'Sports': Color(0xFF00BCD4),
    'Home & Garden': Color(0xFF8BC34A),
    'Other': Color(0xFF9E9E9E),
  };

  // Contoh gambar dari internet (Picsum Photos) / Sample internet images (from Picsum Photos)
  static const List<String> sampleImages = [
    'https://picsum.photos/seed/catalog1/600/400',
    'https://picsum.photos/seed/catalog2/600/400',
    'https://picsum.photos/seed/catalog3/600/400',
    'https://picsum.photos/seed/catalog4/600/400',
    'https://picsum.photos/seed/catalog5/600/400',
    'https://picsum.photos/seed/catalog6/600/400',
  ];
}
