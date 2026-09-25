import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';

class GetHistory {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  Future<List<ConversionRecord>> call() => _repository.getHistory();
}
