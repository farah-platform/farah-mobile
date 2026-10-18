import 'package:farah/data/models/home/userhome_model.dart';
import 'package:flutter/material.dart';

class HomeHeaderWidget extends StatelessWidget {
  final UserHomeModel? user;
  final VoidCallback? onNotificationTap;

  const HomeHeaderWidget({
    super.key,
    required this.user,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = (user?.name != null && user!.name.isNotEmpty)
        ? user!.name
        : 'مستخدم';
    final location = (user?.location != null && user!.location.isNotEmpty)
        ? user!.location
        : 'غزة';

    return SizedBox(
      height: 54,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withOpacity(.07),
            ),
            child: CircleAvatar(
              backgroundColor: colors.primary.withOpacity(.07),
              backgroundImage:
                  (user?.avatar != null && user!.avatar!.isNotEmpty)
                  ? NetworkImage(user!.avatar!)
                  : null,
              child: (user?.avatar == null || user!.avatar!.isEmpty)
                  ? Icon(
                      Icons.person_outline_rounded,
                      color: colors.primary,
                      size: 25,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 9),

          // User Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً، $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: colors.onSurface.withOpacity(.45),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification Button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.outline.withOpacity(.15)),
            ),
            child: Stack(
              children: [
                Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onNotificationTap ?? () {},
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: colors.primary,
                      size: 21,
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
