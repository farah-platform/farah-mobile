import 'package:flutter/material.dart';

class ProviderHomeHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const ProviderHomeHeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          // Add image if available
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data['category_name'] ?? 'مستلزمات أفراح وهدايا',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }
}
