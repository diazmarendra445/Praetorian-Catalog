import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../models/item_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/item_card.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ANIMASI 2: Staggered animation untuk item di grid / ANIMATION 2: Staggered animation for grid items
  late AnimationController _staggerController;
  List<Animation<double>> _itemAnimations = [];

  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final itemProvider = context.read<ItemProvider>();

    if (authProvider.user != null) {
      await itemProvider.fetchItems(authProvider.user!.id);
      _rebuildAnimations(itemProvider.items.length);
      _staggerController.forward(from: 0);
    }
  }

  void _rebuildAnimations(int count) {
    _itemAnimations = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Dialog Tambah Item / Add Item Dialog ─────────────────────
  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController(
      text: AppConfig.sampleImages[DateTime.now().millisecond % AppConfig.sampleImages.length],
    );
    String selectedCategory = AppConfig.categories.first;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tambah Item Baru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppConfig.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'Nama Item',
                        hint: 'Nama item koleksimu',
                        controller: titleController,
                        prefixIcon: Icons.label_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama item wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Deskripsi',
                        hint: 'Deskripsi item (opsional)',
                        controller: descController,
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'URL Gambar',
                        hint: 'https://picsum.photos/600/400',
                        controller: imageController,
                        prefixIcon: Icons.image_outlined,
                      ),
                      const SizedBox(height: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.category_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            items: AppConfig.categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                setSheetState(() => selectedCategory = v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Consumer<ItemProvider>(
                        builder: (_, itemProv, __) => CustomButton(
                          text: 'Tambah Item',
                          isLoading: itemProv.isLoading,
                          icon: Icons.add_circle_outline,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final authProvider = context.read<AuthProvider>();
                            final success = await itemProv.createItem(
                              userId: authProvider.user!.id,
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              imageUrl: imageController.text.trim(),
                              category: selectedCategory,
                            );
                            if (success && sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                              _rebuildAnimations(itemProv.items.length);
                              _staggerController.forward(from: 0);
                              _showSnackbar('Item berhasil ditambahkan! 🎉', true);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackbar(String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? AppConfig.successColor : AppConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── UI / UI ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: SafeArea(
        child: Consumer2<AuthProvider, ItemProvider>(
          builder: (context, auth, itemProv, _) {
            return RefreshIndicator(
              onRefresh: _loadData,
              color: AppConfig.primaryColor,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(auth, itemProv)),
                  SliverToBoxAdapter(child: _buildSearchBar(itemProv)),
                  SliverToBoxAdapter(child: _buildCategoryFilter(itemProv)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  if (itemProv.isLoading && itemProv.items.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppConfig.primaryColor),
                      ),
                    )
                  else if (itemProv.items.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final item = itemProv.items[i];
                            final anim = i < _itemAnimations.length
                                ? _itemAnimations[i]
                                : null;
                            return ItemCard(
                              item: item,
                              animation: anim,
                              onTap: () => _navigateToDetail(item),
                              onDelete: () async {
                                final ok = await itemProv.deleteItem(item.id);
                                if (ok && mounted) {
                                  _rebuildAnimations(itemProv.items.length);
                                  _staggerController.forward(from: 0);
                                  _showSnackbar('Item dihapus', true);
                                }
                              },
                            );
                          },
                          childCount: itemProv.items.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth, ItemProvider itemProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${auth.user?.firstName ?? 'User'} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppConfig.secondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${itemProv.itemCount} item dalam koleksimu',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) => _loadData()),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConfig.primaryColor, Color(0xFF9C94FF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  auth.user?.firstName.characters.first.toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ItemProvider itemProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (q) {
          itemProv.search(q);
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Cari item koleksimu...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    itemProv.search('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ItemProvider itemProv) {
    final categories = ['All', ...AppConfig.categories];
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              itemProv.filterByCategory(cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppConfig.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppConfig.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Koleksi masih kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah item pertamamu sekarang!',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Tambah Item',
            onPressed: _showAddItemDialog,
            icon: Icons.add,
            width: 180,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
    ).then((_) => _loadData());
  }
}
