import 'package:currency_converter/features/history/data/models/conversion_record_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  test('toMap / fromMap round-trips every field', () {
    final model = ConversionRecordModel.fromEntity(
      sampleRecord(id: 7, isCached: true),
    );

    final restored = ConversionRecordModel.fromMap(model.toMap());

    expect(restored.id, 7);
    expect(restored.from, 'USD');
    expect(restored.to, 'EGP');
    expect(restored.amount, 1);
    expect(restored.rate, 48);
    expect(restored.rateDate, DateTime(2026, 9, 24));
    expect(restored.createdAt, DateTime(2026, 9, 25, 10, 30));
    expect(restored.isCached, isTrue);
  });

  test('toMap omits id for new records so SQLite can assign it', () {
    final map = ConversionRecordModel.fromEntity(sampleRecord()).toMap();

    expect(map.containsKey('id'), isFalse);
  });

  test('missing is_cached column defaults to live', () {
    final map = ConversionRecordModel.fromEntity(sampleRecord(id: 1)).toMap()
      ..remove('is_cached');

    expect(ConversionRecordModel.fromMap(map).isCached, isFalse);
  });

  test('entity computes converted amount and inverse rate', () {
    final record = sampleRecord(amount: 2, rate: 50);

    expect(record.convertedAmount, 100);
    expect(record.inverseRate, 0.02);
  });
}
