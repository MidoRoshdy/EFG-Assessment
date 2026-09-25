import 'package:currency_converter/core/error/exceptions.dart';
import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/history/data/datasources/history_local_data_source.dart';
import 'package:currency_converter/features/history/data/models/conversion_record_model.dart';
import 'package:currency_converter/features/history/data/repositories/history_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

class _BrokenLocal implements HistoryLocalDataSource {
  @override
  Future<List<ConversionRecordModel>> getAll() =>
      throw const CacheException('disk full');

  @override
  Future<ConversionRecordModel> insert(ConversionRecordModel record) =>
      throw const CacheException('disk full');

  @override
  Future<void> delete(int id) => throw const CacheException('disk full');
}

void main() {
  final repository = HistoryRepositoryImpl(_BrokenLocal());

  test('maps CacheException to CacheFailure on read', () {
    expect(repository.getHistory, throwsA(isA<CacheFailure>()));
  });

  test('maps CacheException to CacheFailure on save', () {
    expect(() => repository.save(sampleRecord()), throwsA(isA<CacheFailure>()));
  });

  test('maps CacheException to CacheFailure on delete', () {
    expect(() => repository.delete(1), throwsA(isA<CacheFailure>()));
  });
}
