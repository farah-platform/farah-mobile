import 'package:farah/view/screens/auth/sginup.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<_OnboardingItem> items = const [
    _OnboardingItem(
      title: 'كل الخدمات التي تحتاجها\nفي مكان واحد',
      subtitle: 'تصفح مجموعة واسعة من مزودي الخدمات الموثوقين بالقرب منك',
      imagePath: 'assets/image/onp1.png',
    ),
    _OnboardingItem(
      title: 'وقتك أهم من أنك تضيعه\nبالبحث',
      subtitle: 'احجز خدمتك بخطوات بسيطة وبدون اي تعقيد',
      imagePath: 'assets/image/onp2.png',
    ),
    _OnboardingItem(
      title: 'مزودين موثوقين وتقييمات\nحقيقية',
      subtitle: 'كل مزود خدمة تمت مراجعة ملفه وكل تقييم من عميل فعلي',
      imagePath: 'assets/image/onp3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkipPressed() {
    // مؤقت للتجربة، هيتشال لما ينربط الـ Cubit
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void _onNextPressed() {
    if (currentPage == items.length - 1) {
      // مؤقت للتجربة، هيتشال لما ينربط الـ Cubit
      Navigator.pushReplacementNamed(context, '/signup');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isLastPage = currentPage == items.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: Text(
                      'تخطي',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_outlined,
                                    size: 100,
                                    color: Colors.grey.shade300,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final isActive = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 24 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? primary : primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: Text(isLastPage ? 'ابدأ الان' : 'التالي'),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
