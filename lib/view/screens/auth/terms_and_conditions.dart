import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool acceptedTerms = false;

  final List<String> terms = const [
    'يلتزم المستخدم بإدخال بيانات صحيحة ودقيقة ومحدثة عند إنشاء الحساب واستخدام تطبيق فرحتنا.',
    'يتحمل المستخدم مسؤولية الحفاظ على سرية بيانات حسابه، ويتحمل كامل المسؤولية عن أي نشاط يتم من خلاله.',
    'يتيح تطبيق فرحتنا للمستخدمين استعراض مزودي خدمات الأفراح والتواصل معهم وإجراء الحجوزات، بينما تتم الاتفاقات النهائية بين المستخدم ومزود الخدمة وفقًا للشروط المتفق عليها بين الطرفين.',
    'يلتزم المستخدم باستخدام التطبيق بطريقة قانونية وأخلاقية، وعدم إساءة استخدام المنصة أو نشر أي محتوى مخالف أو مضلل.',
    'تخضع الحجوزات وسياسات الإلغاء أو التعديل أو الاسترجاع للشروط التي يحددها كل مزود خدمة، ولا يتحمل تطبيق فرحتنا مسؤولية أي نزاع ينشأ بين الطرفين.',
    'يحتفظ تطبيق فرحتنا بحق تعديل أو تحديث شروط الاستخدام أو المزايا في أي وقت، مع نشر التحديثات داخل التطبيق عند الحاجة.',
    'يجمع التطبيق بعض البيانات اللازمة لتشغيل الخدمات وتحسين تجربة المستخدم، ويتم التعامل معها وفقًا لسياسة الخصوصية.',
    'باستخدام تطبيق فرحتنا، يوافق المستخدم على استلام الإشعارات المتعلقة بالحجوزات، وتحديثات الطلبات، والعروض، والتنبيهات المهمة الخاصة بالتطبيق.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      "الشروط والاحكام",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "مرحبًا بك في",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "تطبيق فرحتنا لإدارة المناسبات والخدمات .",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "يرجى قراءة الشروط التالية بعناية قبل استخدام التطبيق:",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...List.generate(terms.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}.  ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      terms[index],
                                      textAlign: TextAlign.right,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(height: 1.6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          Text(
                            'سياسة الخصوصية:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'نلتزم بحماية بياناتك الشخصية وعدم مشاركتها مع أي جهة خارجية إلا عند الحاجة لتقديم الخدمة أو وفقًا للأنظمة المعمول بها.',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "قبول الشروط والاحكام",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: acceptedTerms,
                          activeColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              acceptedTerms = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: acceptedTerms ? () {} : null,
                      child: const Text("المتابعة"),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
