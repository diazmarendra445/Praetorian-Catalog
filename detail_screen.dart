import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class DetailScreen extends StatefulWidget {
  final ItemModel item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late ItemModel _item;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late String _selectedCategory;

  // ─── Animasi: Scale untuk dialog sukses / Animation: Scale for success dialog
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _titleController = TextEditingController(text: _item.title);
    _descController = TextEditingController(text: _item.description);
    _imageController = TextEditingController(text: _item.imageUrl);
    _selectedCategory = _item.category;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── PERBARUI / UPDATE ───────────────────────────────────────
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final itemProv = context.read<ItemProvider>();
    final success = await itemProv.updateItem(
      itemId: _item.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: _imageController.text.trim(),
      category: _selectedCategory,
    );

    if (success && mounted) {
      // Perbarui state lokal / Update local state
      setState(() {
        _item = _item.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          imageUrl: _imageController.text.trim(),
          category: _selectedCategory,
        );
        _isEditing = false;
      });
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itemProv.errorMessage),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    }
  }

  // ─── Dialog Sukses / Success Dialog ──────────────────────────
  void _showSuccessDialog() {
    _pulseController.forward(from: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Ikon Sukses Beranimasi / Animated Success Icon ──
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppConfig.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppConfig.successColor,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Berhasil Diperbarui!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppConfig.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Item "${_item.title}" berhasil diperbarui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'OK',
                onPressed: () => Navigator.pop(context),
                icon: Icons.done_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── UI / UI ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // ── Sliver App Bar dengan Gambar Hero / Sliver App Bar with Hero Image ──
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppConfig.primaryColor,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 16, color: AppConfig.secondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isEditing ? Icons.close : Icons.edit_outlined,
                      size: 18,
                      color: AppConfig.secondaryColor,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        // Reset field jika batal / Reset fields if cancel
                        _titleController.text = _item.title;
                        _descController.text = _item.description;
                        _imageController.text = _item.imageUrl;
                        _selectedCategory = _item.category;
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar dari internet / Internet Image
                    _item.imageUrl.isNotEmpty
                        ? Image.network(
                            _item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                    // Gradient overlay / Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Konten / Content ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge kategori + tanggal / Category badge + date
                    Row(
                      children: [
                        _buildCategoryBadge(),
                        const Spacer(),
                        Text(
                          'Ditambahkan: ${_item.formattedDate}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Mode Edit / Edit Mode ────────────────────
                    if (_isEditing) ...[
                      _buildEditForm(),
                    ] else ...[
                      _buildReadView(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Tombol Konfirmasi Bawah / Bottom Confirm Button ───────
      bottomNavigationBar: _isEditing
          ? Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Consumer<ItemProvider>(
                builder: (_, itemProv, __) => CustomButton(
                  text: 'Simpan Perubahan',
                  onPressed: _handleUpdate,
                  isLoading: itemProv.isLoading,
                  icon: Icons.save_outlined,
                ),
              ),
            )
          : null,
    );
  }

  // ─── Tampilan Baca / Read View ────────────────────────────────
  Widget _buildReadView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _item.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppConfig.secondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        if (_item.description.isNotEmpty) ...[
          const Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _item.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Tampilan URL Gambar / Image URL display
        if (_item.imageUrl.isNotEmpty) ...[
          const Text(
            'URL Gambar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _item.imageUrl,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Info tip / Info tip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConfig.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppConfig.primaryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap ikon edit di atas untuk mengubah data item ini.',
                  style: TextStyle(
                      fontSize: 12, color: AppConfig.primaryColor.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Formulir Edit / Edit Form ────────────────────────────────
  Widget _buildEditForm() {
    return StatefulBuilder(
      builder: (ctx, setFormState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Item',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppConfig.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Nama Item',
              controller: _titleController,
              prefixIcon: Icons.label_outline,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Nama item wajib diisi'
                  : null,
            ),
            const SizedBox(height: 14),

            CustomTextField(
              label: 'Deskripsi',
              controller: _descController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            CustomTextField(
              label: 'URL Gambar',
              controller: _imageController,
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
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_outlined,
                        size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: AppConfig.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setFormState(() => _selectedCategory = v!),
                ),
              ],
            ),
            const SizedBox(height: 80), // Ruang untuk bottom bar / Space for bottom bar
          ],
        );
      },
    );
  }

  Widget _buildCategoryBadge() {
    final color =
        AppConfig.categoryColors[_item.category] ?? AppConfig.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppConfig.categoryIcons[_item.category] ?? Icons.category,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            _item.category,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final color =
        AppConfig.categoryColors[_item.category] ?? AppConfig.primaryColor;
    return Container(
      color: color.withOpacity(0.15),
      child: Center(
        child: Icon(
          AppConfig.categoryIcons[_item.category] ?? Icons.category,
          color: color,
          size: 80,
        ),
      ),
    );
  }
}
