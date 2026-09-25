import 'package:currency_converter/core/widgets/app_details_card.dart';
import 'package:currency_converter/core/widgets/app_empty_view.dart';
import 'package:currency_converter/core/widgets/app_error_view.dart';
import 'package:currency_converter/core/widgets/app_list_item.dart';
import 'package:currency_converter/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppPrimaryButton', () {
    testWidgets('calls onPressed when idle', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWidget(AppPrimaryButton(label: 'Go', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Go'));

      expect(taps, 1);
    });

    testWidgets('shows spinner and ignores taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWidget(
          AppPrimaryButton(
            label: 'Go',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));

      expect(find.text('Go'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(taps, 0);
    });
  });

  group('AppErrorView', () {
    testWidgets('shows message and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapWidget(
          AppErrorView(message: 'Boom', onRetry: () => retried = true),
        ),
      );

      expect(find.text('Boom'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry when no callback', (tester) async {
      await tester.pumpWidget(wrapWidget(const AppErrorView(message: 'Boom')));

      expect(find.text('Retry'), findsNothing);
    });
  });

  testWidgets('AppEmptyView shows title and message', (tester) async {
    await tester.pumpWidget(
      wrapWidget(const AppEmptyView(title: 'Nothing', message: 'Add some')),
    );

    expect(find.text('Nothing'), findsOneWidget);
    expect(find.text('Add some'), findsOneWidget);
  });

  testWidgets('AppDetailsCard renders title and every row', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const AppDetailsCard(
          title: 'Details',
          items: [AppDetailItem('A', '1'), AppDetailItem('B', '2')],
        ),
      ),
    );

    expect(find.text('Details'), findsOneWidget);
    for (final text in ['A', '1', 'B', '2']) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('AppListItem renders content and handles taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapWidget(
        AppListItem(
          title: 'Title',
          subtitle: 'Subtitle',
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Subtitle'), findsOneWidget);
    await tester.tap(find.text('Title'));
    expect(tapped, isTrue);
  });
}
