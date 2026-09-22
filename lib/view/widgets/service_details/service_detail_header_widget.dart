import 'package:flutter/material.dart';

class ServiceDetailHeaderWidget extends StatefulWidget {
  final List<String> images;
  final bool isFavorited;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;

  const ServiceDetailHeaderWidget({
    super.key,
    required this.images,
    required this.isFavorited,
    required this.onBackTap,
    required this.onFavoriteTap,
  });

  @override
  State<ServiceDetailHeaderWidget> createState() =>
      _ServiceDetailHeaderWidgetState();
}

class _ServiceDetailHeaderWidgetState extends State<ServiceDetailHeaderWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // معرض الصور
          if (widget.images.isNotEmpty)
            PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.image_outlined,
                size: 60,
                color: colors.onSurfaceVariant,
              ),
            ),

          // تدرج ظلي خفيف لأزرار التحكم
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          // شريط الأزرار العلوي
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر المفضلة
                _buildCircleButton(
                  onTap: widget.onFavoriteTap,
                  icon: widget.isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: widget.isFavorited
                      ? colors.primary
                      : colors.onSurface,
                ),

                // زر الرجوع
                _buildCircleButton(
                  onTap: widget.onBackTap,
                  icon: Icons.arrow_forward_rounded,
                  iconColor: colors.onSurface,
                ),
              ],
            ),
          ),

          // مؤشر النقاط (Indicators)
          if (widget.images.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? colors.primary
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
