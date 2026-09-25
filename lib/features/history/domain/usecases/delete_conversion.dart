import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';

class DeleteConversion {
  const DeleteConversion(this._repository);

  final HistoryRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
