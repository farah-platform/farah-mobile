import 'package:flutter/material.dart';

class ServiceBottomActionBarWidget extends StatelessWidget {
  final VoidCallback onBookNowTap;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onShareTap;

  const ServiceBottomActionBarWidget({
    super.key,
    required this.onBookNowTap,
    required this.onWhatsAppTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر المشاركة
            _buildIconButton(
              onTap: onShareTap,
              icon: Icons.share_outlined,
              colors: colors,
            ),
            const SizedBox(width: 8),

            // زر الواتساب / المحادثة
            _buildIconButton(
              onTap: onWhatsAppTap,
              icon: Icons.chat_bubble_outline_rounded,
              colors: colors,
            ),
            const SizedBox(width: 10),

            // زر المواصلة للحجز العريض
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onBookNowTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'المواصلة للحجز',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onTap,
    required IconData icon,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 19, color: colors.primary),
      ),
    );
  }
}
