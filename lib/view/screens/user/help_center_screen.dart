import 'package:farah/core/constants/app_colors.dart';
import 'package:farah/core/utils/support_contact.dart';
import 'package:farah/cubits/help_center/help_center_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: مركز مساعدة العميل: الأسئلة من السيرفر (audience=customer) و"تواصل معنا"
// من بيانات الدعم في لوحة الأدمن، بدل الأسئلة الثابتة ورقم الواتساب المكتوب بالكود.

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<HelpCenterCubit>().load();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> faqs) {
    final query = _query.trim();
    if (query.isEmpty) return faqs;
    return faqs
        .where((f) => '${f['question']} ${f['answer']}'.contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'مركز المساعدة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFBF8F8),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن مشكلتك',
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: const Color(0xFFFBF8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<HelpCenterCubit, HelpCenterState>(
              builder: (context, state) {
                final faqs = _filtered(state.faqs);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'الأسئلة الشائعة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Material(
                      // فرح: Material حتى يظهر أثر الضغط على الأسئلة القابلة للفتح.
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(12),
                      child: state.loading
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : state.error != null
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    state.error!,
                                    textAlign: TextAlign.center,
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        context.read<HelpCenterCubit>().load(),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            )
                          : faqs.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  _query.trim().isEmpty
                                      ? 'لا توجد أسئلة شائعة حالياً'
                                      : 'لا توجد نتائج',
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                for (final faq in faqs)
                                  _FaqTile(
                                    question: faq['question']?.toString() ?? '',
                                    answer: faq['answer']?.toString() ?? '',
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: state.loading
                            ? null
                            : () => openSupportContact(
                                context,
                                phone: state.supportPhone,
                                email: state.supportEmail,
                              ),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text(
                          'تواصل معنا',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
