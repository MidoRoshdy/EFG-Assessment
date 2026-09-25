import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';

abstract interface class HistoryRepository {
  Future<List<ConversionRecord>> getHistory();

  Future<ConversionRecord> save(ConversionRecord record);

  Future<void> delete(int id);
}
