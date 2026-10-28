import 'package:farah/core/utils/support_contact.dart';
import 'package:farah/cubits/help_center/help_center_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: "مركز المساعدة" للمزود: بحث، أسئلة شائعة من السيرفر (يديرها الأدمن من لوحة التحكم ← الأسئلة الشائعة)،
// و"تواصل معنا" يستخدم هاتف/بريد الدعم من إعدادات المنصة. إذا لم يعبّئها الأدمن تظهر رسالة "غير متاحة".
class ProviderHelpCenterScreen extends StatefulWidget {
  const ProviderHelpCenterScreen({super.key});

  @override
  State<ProviderHelpCenterScreen> createState() =>
      _ProviderHelpCenterScreenState();
}

class _ProviderHelpCenterScreenState extends State<ProviderHelpCenterScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<HelpCenterCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'مركز المساعدة'),
      body: BlocBuilder<HelpCenterCubit, HelpCenterState>(
        builder: (context, state) {
          final query = _query.trim();
          final faqs = query.isEmpty
              ? state.faqs
              : state.faqs
                    .where(
                      (f) => '${f['question']} ${f['answer']}'.contains(query),
                    )
                    .toList();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مشكلتك',
                        hintStyle: const TextStyle(color: Colors.black45),
                        suffixIcon: Icon(Icons.search, color: primary),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: Color(0xFFDADADA),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: Color(0xFFDADADA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'الأسئلة الشائعة',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.error != null)
                      Column(
                        children: [
                          Text(state.error!, textAlign: TextAlign.center),
                          TextButton.icon(
                            onPressed: () =>
                                context.read<HelpCenterCubit>().load(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      )
                    else if (faqs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          query.isEmpty
                              ? 'لا توجد أسئلة شائعة حالياً'
                              : 'لا توجد نتائج مطابقة',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      for (final faq in faqs) _faqCard(faq, primary),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: state.loading
                          ? null
                          : () => openSupportContact(
                              context,
                              phone: state.supportPhone,
                              email: state.supportEmail,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'تواصل معنا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _faqCard(Map<String, dynamic> faq, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E2E2)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            iconColor: primary,
            collapsedIconColor: primary,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(
              faq['question']?.toString() ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            children: [
              Text(
                faq['answer']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
