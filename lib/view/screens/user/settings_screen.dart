import 'package:farah/core/constants/app_colors.dart';
import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/settings/settings_cubit.dart';
import 'package:farah/view/widgets/common/skeleton_box.dart';
import 'package:farah/view/widgets/settings/delete_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
  }

  Future<void> _navigateAndReload(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) context.read<SettingsCubit>().load();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: const DeleteAccountDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldSecondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildProfileCard(state),
              const SizedBox(height: 20),
              _buildAccountSection(state),
              const SizedBox(height: 16),
              _buildPreferencesSection(state),
              const SizedBox(height: 16),
              _buildActivitySection(),
              const SizedBox(height: 16),
              _buildSupportSection(),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
              const SizedBox(height: 8),
              _buildDeleteAccountButton(context),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(SettingsState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (state is SettingsLoading)
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFE0E0E0),
            )
          else if (state is SettingsLoaded)
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                _initials(state.user.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          else
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFE0E0E0),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: state is SettingsLoading
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 16),
                      SizedBox(height: 8),
                      SkeletonBox(width: 100, height: 12),
                    ],
                  )
                : state is SettingsLoaded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.user.phone,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : const Text('—'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('الحساب'),
        const SizedBox(height: 8),
        _buildTilesCard([
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'تعديل الملف الشخصي',
            onTap: () => _navigateAndReload(AppRoutes.profileEdit),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'تغيير كلمة المرور',
            onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
          ),
        ]),
      ],
    );
  }

  Widget _buildPreferencesSection(SettingsState state) {
    final notificationsEnabled =
        state is SettingsLoaded ? state.notificationsEnabled : true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('التفضيلات'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            dense: true,
            minLeadingWidth: 24,
            leading: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
            title: const Text('الإشعارات'),
            trailing: Switch(
              value: notificationsEnabled,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              onChanged: (val) =>
                  context.read<SettingsCubit>().toggleNotifications(val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('النشاط'),
        const SizedBox(height: 8),
        _buildTilesCard([
          const _SettingsTile(
            icon: Icons.history,
            label: 'سجل الحجوزات',
            disabled: true,
          ),
          _SettingsTile(
            icon: Icons.favorite_border,
            label: 'المفضلة',
            onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
          ),
          const _SettingsTile(
            icon: Icons.star_border,
            label: 'تقييماتي',
            disabled: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('الدعم'),
        const SizedBox(height: 8),
        _buildTilesCard([
          _SettingsTile(
            icon: Icons.help_outline,
            label: 'مركز المساعدة',
            onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'الشروط والأحكام',
            onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
          ),
        ]),
      ],
    );
  }

  Widget _buildTilesCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(tiles.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(height: 1, indent: 56);
          }
          return tiles[i ~/ 2];
        }),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          final nav = Navigator.of(context);
          context.read<AuthCubit>().logout().then((_) {
            nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          });
        },
        child: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _showDeleteDialog,
        child: const Text(
          'حذف الحساب',
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '؟';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts.last.characters.first}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = disabled ? Colors.grey.shade400 : AppColors.primary;
    final textColor = disabled ? Colors.grey.shade400 : Colors.black87;

    return ListTile(
      dense: true,
      minLeadingWidth: 24,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: disabled ? null : onTap,
    );
  }
}
