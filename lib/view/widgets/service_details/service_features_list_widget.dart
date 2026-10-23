import 'package:flutter/material.dart';

class ServiceFeaturesListWidget extends StatefulWidget {
  final List<String> features;
  final List<String> removableFeatures;

  const ServiceFeaturesListWidget({
    super.key,
    required this.features,
    this.removableFeatures = const [],
  });

  @override
  State<ServiceFeaturesListWidget> createState() =>
      _ServiceFeaturesListWidgetState();
}

class _ServiceFeaturesListWidgetState extends State<ServiceFeaturesListWidget> {
  // تخزين حالة كل ميزة: هل هي مشمولة أم تمت إزالتها
  final Map<String, String> _featureStatuses = {};

  @override
  void initState() {
    super.initState();
    // الوضع الافتراضي لجميع الميزات هو "مشمولة"
    for (var f in widget.features) {
      _featureStatuses[f] = 'مشمولة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (widget.features.isEmpty) return const SizedBox.shrink();

    // تغليف بـ Directionality لضمان العرض من اليمين لليسار
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مميزات الخدمة',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: widget.features.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final feature = widget.features[index];
              final status = _featureStatuses[feature] ?? 'مشمولة';

              // فرح: المزود هو اللي بيحدد شو قابل للإزالة (removable_features)، مش التطبيق.
              // TODO: API الحجز ما فيه حقل للمزايا المُزالة بعد، فالاختيار يظهر للعميل فقط.
              final isMandatory = !widget.removableFeatures.contains(feature);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.outline.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    // 1. الأيقونة (أول شيء على اليمين)
                    Icon(
                      status == 'قابلة للإزالة'
                          ? Icons.remove_circle_outline_rounded
                          : Icons.check_circle_rounded,
                      color: status == 'قابلة للإزالة'
                          ? colors.outline.withOpacity(0.4)
                          : colors.primary,
                      size: 18,
                    ),

                    const SizedBox(width: 10),

                    // 2. اسم الخدمة المميزة (في المنتصف)
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: status == 'قابلة للإزالة'
                              ? colors.onSurface.withOpacity(0.4)
                              : colors.onSurface,
                          decoration: status == 'قابلة للإزالة'
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),

                    // 3. زر الخيارات وشارة الحالة (على اليسار)
                    if (!isMandatory)
                      GestureDetector(
                        onTap: () => _showOptionsDialog(context, feature),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                      ),

                    if (!isMandatory) const SizedBox(width: 8),

                    // شارة الحالة "مشمولة" (أقصى اليسار)
                    _buildStatusBadge(status, colors, theme),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colors, ThemeData theme) {
    final isIncluded = status == 'مشمولة';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isIncluded
            ? colors.primary.withOpacity(0.08)
            : colors.outline.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isIncluded
              ? colors.primary
              : colors.onSurface.withOpacity(0.6),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, String feature) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.check_rounded, color: colors.primary),
                    title: const Text('مشمولة'),
                    onTap: () {
                      setState(() => _featureStatuses[feature] = 'مشمولة');
                      Navigator.pop(sheetContext);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.close_rounded,
                      color: Colors.redAccent,
                    ),
                    title: const Text('قابلة للإزالة'),
                    onTap: () {
                      setState(
                        () => _featureStatuses[feature] = 'قابلة للإزالة',
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
