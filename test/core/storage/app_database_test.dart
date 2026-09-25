import 'dart:io';

import 'package:currency_converter/core/storage/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<List<String>> columnsOf(Database db, String table) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.map((r) => r['name'] as String).toList();
  }

  test('fresh install creates all tables', () async {
    final db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(db.close);

    expect(
      await columnsOf(db, AppDatabase.conversionsTable),
      containsAll(['id', 'from_currency', 'rate', 'is_cached']),
    );
    expect(await columnsOf(db, AppDatabase.ratesCacheTable), isNotEmpty);
    expect(await columnsOf(db, AppDatabase.currenciesCacheTable), isNotEmpty);
  });

  test('upgrading from v1 keeps history and adds new schema', () async {
    final dir = await Directory.systemTemp.createTemp('db_test');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'test.db');

    final v1 = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE conversions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              from_currency TEXT NOT NULL,
              to_currency TEXT NOT NULL,
              amount REAL NOT NULL,
              rate REAL NOT NULL,
              rate_date TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.insert('conversions', {
            'from_currency': 'USD',
            'to_currency': 'EUR',
            'amount': 10,
            'rate': 0.9,
            'rate_date': '2026-09-24',
            'created_at': '2026-09-25T10:00:00',
          });
        },
      ),
    );
    await v1.close();

    final db = await AppDatabase.open(factory: databaseFactoryFfi, path: path);
    addTearDown(db.close);

    final rows = await db.query(AppDatabase.conversionsTable);
    expect(rows, hasLength(1));
    expect(rows.single['is_cached'], 0);
    expect(await columnsOf(db, AppDatabase.ratesCacheTable), isNotEmpty);
  });
}
