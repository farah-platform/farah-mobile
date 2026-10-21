import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_settings/provider_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "الاعدادات" (حسابي tab) for providers.
class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  static const _border = Color(0xFFDCDCDC);
  static const _red = Color(0xFFD9473F);

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProviderSettingsCubit>();
    if (cubit.state.notificationsEnabled == null) cubit.load();
  }

  // فرح: بعد حفظ بيانات المتجر أو الملف الشخصي نعيد تحميل اللوحة حتى تظهر الصورة والاسم الجديدين.
  Future<void> _open(String route) async {
    final dashboard = context.read<ProviderDashboardCubit>();
    final saved = await Navigator.pushNamed(context, route);
    if (saved == true && mounted) dashboard.loadDashboard(refresh: true);
  }

  void _logout() {
    final auth = context.read<AuthCubit>();
    // Leave the provider screens first so their guard does not redirect.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final dashboard = context.watch<ProviderDashboardCubit>().state;
    final data = dashboard is ProviderDashboardLoaded
        ? dashboard.data
        : const <String, dynamic>{};

    return BlocListener<ProviderSettingsCubit, ProviderSettingsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        children: [
          Center(
            child: Text(
              'الاعدادات',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _header(data, primary),
          _section('الحساب'),
          _group([
            _item(
              Icons.person_outline,
              'تعديل الملف الشخصي',
              primary,
              () => _open(AppRoutes.providerProfileEdit),
            ),
            _item(
              Icons.lock_outline,
              'تغيير كلمة المرور',
              primary,
              () => _open(AppRoutes.providerChangePassword),
            ),
            _item(
              Icons.star_border,
              'الاشتراك  الحالي',
              primary,
              () => _open(AppRoutes.providerCurrentSubscription),
            ),
          ]),
          _section('التفضيلات'),
          _group([
            BlocBuilder<ProviderSettingsCubit, ProviderSettingsState>(
              builder: (context, state) => _row(
                Icons.notifications_none_rounded,
                'الاشعارات',
                primary,
                trailing: Switch(
                  value: state.notificationsEnabled ?? true,
                  activeTrackColor: const Color(0xFF5A0423),
                  activeThumbColor: Colors.white,
                  onChanged: state.notificationsEnabled == null
                      ? null
                      : (v) => context
                            .read<ProviderSettingsCubit>()
                            .setNotifications(v),
                ),
              ),
            ),
          ]),
          _section('المتجر'),
          _group([
            _item(
              Icons.history,
              'بيانات المتجر',
              primary,
              () => _open(AppRoutes.providerStoreProfile),
            ),
            _item(
              Icons.favorite_border,
              'حساب استلام الارباح',
              primary,
              () => _open(AppRoutes.providerPayoutAccount),
            ),
            _item(
              Icons.star_border,
              'تقييماتي',
              primary,
              () => _open(AppRoutes.providerReviews),
            ),
          ]),
          _section('الدعم'),
          _group([
            _item(
              Icons.help_outline,
              'مركز المساعدة',
              primary,
              () => _open(AppRoutes.providerHelpCenter),
            ),
            _item(
              Icons.description_outlined,
              'الشروط والاحكام',
              primary,
              () => _open(AppRoutes.terms),
            ),
          ]),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: Color(0xFFEDE6E8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16)),
            ),
          ),
          TextButton(
            // فرح: يفتح شاشة "حذف الحساب" حسب التصميم بدل نافذة التأكيد.
            onPressed: () => _open(AppRoutes.providerDeleteAccount),
            child: const Text(
              'حذف الحساب',
              style: TextStyle(color: _red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(Map<String, dynamic> data, Color primary) {
    final provider = (data['provider'] as Map?) ?? const {};
    final avatar = provider['avatar']?.toString();
    final active = (data['subscription'] as Map?)?['is_active'] == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: primary.withValues(alpha: 0.12),
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage(avatar)
                : null,
            child: avatar == null || avatar.isEmpty
                ? Icon(Icons.storefront_outlined, color: primary, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider['business_name']?.toString() ?? '',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  (provider['category'] as Map?)?['name']?.toString() ?? '',
                  style: TextStyle(
                    color: primary.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4E8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF8BC79A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: Color(0xFF2E7D3A)),
                        SizedBox(width: 6),
                        Text(
                          'الاشتراك نشط',
                          style: TextStyle(
                            color: Color(0xFF2E7D3A),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _group(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEDEDED)),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, Color primary, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          ?trailing,
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, Color primary, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: _row(
        icon,
        label,
        primary,
        trailing: Icon(Icons.chevron_left, color: primary, size: 26),
      ),
    );
  }
}
