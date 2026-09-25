import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/history/data/datasources/history_local_data_source.dart';
import 'package:currency_converter/features/history/data/models/conversion_record_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../helpers/fakes.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late HistoryLocalDataSourceImpl dataSource;

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    dataSource = HistoryLocalDataSourceImpl(db);
  });

  tearDown(() => db.close());

  ConversionRecordModel model({String to = 'EGP', DateTime? createdAt}) =>
      ConversionRecordModel.fromEntity(
        sampleRecord(to: to),
      ).copyWithCreatedAt(createdAt ?? DateTime(2026, 9, 25));

  test('insert assigns an id', () async {
    final saved = await dataSource.insert(model());

    expect(saved.id, isNotNull);
  });

  test('getAll returns newest first', () async {
    await dataSource.insert(model(to: 'EUR', createdAt: DateTime(2026, 9, 1)));
    await dataSource.insert(model(to: 'GBP', createdAt: DateTime(2026, 9, 3)));
    await dataSource.insert(model(to: 'JPY', createdAt: DateTime(2026, 9, 2)));

    final all = await dataSource.getAll();

    expect(all.map((r) => r.to), ['GBP', 'JPY', 'EUR']);
  });

  test('delete removes only the given record', () async {
    final a = await dataSource.insert(model(to: 'EUR'));
    await dataSource.insert(model(to: 'GBP'));

    await dataSource.delete(a.id!);

    final all = await dataSource.getAll();
    expect(all.map((r) => r.to), ['GBP']);
  });

  test('data persists offline flag', () async {
    await dataSource.insert(
      ConversionRecordModel.fromEntity(sampleRecord(isCached: true)),
    );

    final all = await dataSource.getAll();

    expect(all.single.isCached, isTrue);
  });
}

extension on ConversionRecordModel {
  ConversionRecordModel copyWithCreatedAt(DateTime createdAt) =>
      ConversionRecordModel(
        id: id,
        from: from,
        to: to,
        amount: amount,
        rate: rate,
        rateDate: rateDate,
        createdAt: createdAt,
        isCached: isCached,
      );
}
