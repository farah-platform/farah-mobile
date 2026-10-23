import 'package:farah/data/models/service_model.dart';
import 'package:farah/view/widgets/service_details/service_bottom_action_bar_widget.dart';
import 'package:farah/view/widgets/service_details/service_features_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: المزايا القابلة للإزالة من السيرفر، وزر واتساب بدون رقم وهمي.

Widget _wrap(Widget child) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(body: child),
  ),
);

void main() {
  test('service reads removable features from the API', () {
    final service = ServiceModel.fromJson({
      'id': 1,
      'title': 'api service',
      'features': ['api fixed', 'api optional'],
      'removable_features': ['api optional'],
    });
    expect(service.removableFeatures, ['api optional']);
  });

  testWidgets('only removable features get the options button', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ServiceFeaturesListWidget(
          features: ['api fixed', 'api optional'],
          removableFeatures: ['api optional'],
        ),
      ),
    );
    expect(find.text('api fixed'), findsOneWidget);
    expect(find.text('api optional'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('whatsapp without a provider number explains instead', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ServiceBottomActionBarWidget(
          onBookNowTap: () {},
          onWhatsAppTap: () {},
          onShareTap: () {},
          serviceTitle: 'api service',
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.pump();
    expect(
      find.text('رقم مقدّم الخدمة غير متاح حالياً، سجّل دخولك أولاً.'),
      findsOneWidget,
    );
  });
}
