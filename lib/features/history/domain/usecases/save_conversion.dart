import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';

class SaveConversion {
  const SaveConversion(this._repository);

  final HistoryRepository _repository;

  Future<ConversionRecord> call(ConversionRecord record) =>
      _repository.save(record);
}
