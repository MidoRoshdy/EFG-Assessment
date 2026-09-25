import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/history/data/models/conversion_record_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class HistoryLocalDataSource {
  Future<List<ConversionRecordModel>> getAll();

  Future<ConversionRecordModel> insert(ConversionRecordModel record);

  Future<void> delete(int id);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  const HistoryLocalDataSourceImpl(this._db);

  final Database _db;

  static const _table = AppDatabase.conversionsTable;

  @override
  Future<List<ConversionRecordModel>> getAll() => _guard(() async {
    final rows = await _db.query(_table, orderBy: 'created_at DESC, id DESC');
    return rows.map(ConversionRecordModel.fromMap).toList();
  });

  @override
  Future<ConversionRecordModel> insert(ConversionRecordModel record) =>
      _guard(() async {
        final id = await _db.insert(_table, record.toMap());
        return record.copyWithId(id);
      });

  @override
  Future<void> delete(int id) =>
      _guard(() => _db.delete(_table, where: 'id = ?', whereArgs: [id]));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw CacheException(e.toString());
    }
  }
}
