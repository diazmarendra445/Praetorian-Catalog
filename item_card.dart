import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/item_model.dart';

class ItemCard extends StatefulWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Animation<double>? animation;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.animation,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.97 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar / Image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar dari internet / Network image from internet
                    widget.item.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppConfig.primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),

                    // Badge kategori / Category badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildCategoryBadge(),
                    ),

                    // Tombol hapus / Delete button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildDeleteButton(context),
                    ),
                  ],
                ),
              ),

              // Info / Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppConfig.secondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.description.isNotEmpty
                            ? widget.item.description
                            : 'Tap untuk lihat detail',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Bungkus dengan animasi jika disediakan (staggered slide animation) /
    // Wrap with animation if provided (staggered slide animation)
    if (widget.animation != null) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: widget.animation!,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: widget.animation!,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildPlaceholder() {
    final color =
        AppConfig.categoryColors[widget.item.category] ?? AppConfig.primaryColor;
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Icon(
          AppConfig.categoryIcons[widget.item.category] ?? Icons.category,
          color: color,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final color =
        AppConfig.categoryColors[widget.item.category] ?? AppConfig.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.item.category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _confirmDelete(context),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.delete_outline, color: Colors.red, size: 16),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Item?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Item "${widget.item.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
