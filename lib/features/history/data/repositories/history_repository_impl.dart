import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/history/data/datasources/history_local_data_source.dart';
import 'package:currency_converter/features/history/data/models/conversion_record_model.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._local);

  final HistoryLocalDataSource _local;

  @override
  Future<List<ConversionRecord>> getHistory() => _guard(_local.getAll);

  @override
  Future<ConversionRecord> save(ConversionRecord record) =>
      _guard(() => _local.insert(ConversionRecordModel.fromEntity(record)));

  @override
  Future<void> delete(int id) => _guard(() => _local.delete(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
