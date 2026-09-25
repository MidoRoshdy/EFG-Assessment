import 'dart:async';

import 'package:currency_converter/core/widgets/app_offline_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('hides the offline banner while online', (tester) async {
    await tester.pumpApp();

    expect(find.byType(AppOfflineBanner), findsNothing);
  });

  testWidgets('shows the offline banner while offline', (tester) async {
    await tester.pumpApp(connectivity: Stream.value(false));

    expect(find.byType(AppOfflineBanner), findsOneWidget);
    expect(find.textContaining('may be outdated'), findsOneWidget);
  });

  testWidgets('toggles the banner as connectivity changes', (tester) async {
    final controller = StreamController<bool>();
    addTearDown(controller.close);

    await tester.pumpApp(connectivity: controller.stream);
    controller.add(false);
    await tester.pumpAndSettle();
    expect(find.byType(AppOfflineBanner), findsOneWidget);

    controller.add(true);
    await tester.pumpAndSettle();
    expect(find.byType(AppOfflineBanner), findsNothing);
  });
}
