import 'package:currency_converter/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('date pads month and day', () {
    expect(DateFormatter.date(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('dateTime pads hour and minute', () {
    expect(
      DateFormatter.dateTime(DateTime(2026, 9, 25, 7, 3)),
      '2026-09-25 07:03',
    );
  });
}
