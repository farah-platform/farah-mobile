import 'package:farah/cubits/provider_onboarding/provider_onboarding_cubit.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/provider_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ProviderRepository {
  @override
  Future<List<dynamic>> getCategories() async => [
    for (var i = 1; i <= 5; i++) {'id': i, 'name': 'api category $i'},
  ];

  @override
  Future<List<dynamic>> getCities() async => [
    {'id': 1, 'name': 'api city'},
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('categories collapse to three tiles and expand with show all', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider(
            create: (_) => ProviderOnboardingCubit(_FakeRepo()),
            child: const ProviderOnboardingScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('بيانات الحساب'), findsOneWidget);
    expect(find.text('api category 3'), findsOneWidget);
    expect(find.text('api category 4'), findsNothing);

    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();
    expect(find.text('api category 5'), findsOneWidget);
  });
}
