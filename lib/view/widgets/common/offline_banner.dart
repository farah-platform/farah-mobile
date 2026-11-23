import 'package:flutter/material.dart';

// فرح: شريط "أنت غير متصل" فوق الشاشة لما تكون البيانات من آخر مرة محفوظة.
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C27A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Color(0xFF9A5B00),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'أنت غير متصل، هذه آخر بيانات محفوظة.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9A5B00)),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('تحديث'),
            ),
        ],
      ),
    );
  }
}
