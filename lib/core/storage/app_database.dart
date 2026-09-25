import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract final class AppDatabase {
  static const _name = 'currency_converter.db';
  static const _version = 3;

  static const conversionsTable = 'conversions';
  static const ratesCacheTable = 'rates_cache';
  static const currenciesCacheTable = 'currencies_cache';

  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), _name);
    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: (db, _) async {
          await _createConversions(db);
          await _createCaches(db);
        },
        onUpgrade: (db, oldVersion, _) async {
          if (oldVersion < 2) await _createCaches(db);
          if (oldVersion < 3) {
            await db.execute(
              'ALTER TABLE $conversionsTable '
              'ADD COLUMN is_cached INTEGER NOT NULL DEFAULT 0',
            );
          }
        },
      ),
    );
  }

  static Future<void> _createConversions(Database db) => db.execute('''
    CREATE TABLE $conversionsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      from_currency TEXT NOT NULL,
      to_currency TEXT NOT NULL,
      amount REAL NOT NULL,
      rate REAL NOT NULL,
      rate_date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      is_cached INTEGER NOT NULL DEFAULT 0
    )
  ''');

  static Future<void> _createCaches(Database db) async {
    await db.execute('''
      CREATE TABLE $ratesCacheTable (
        base TEXT PRIMARY KEY,
        rate_date TEXT NOT NULL,
        rates TEXT NOT NULL,
        fetched_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $currenciesCacheTable (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }
}

final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('databaseProvider not overridden'),
);
