import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/features/history/data/datasources/history_local_data_source.dart';
import 'package:currency_converter/features/history/data/repositories/history_repository_impl.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';
import 'package:currency_converter/features/history/domain/usecases/delete_conversion.dart';
import 'package:currency_converter/features/history/domain/usecases/get_history.dart';
import 'package:currency_converter/features/history/domain/usecases/save_conversion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyLocalDataSourceProvider = Provider<HistoryLocalDataSource>(
  (ref) => HistoryLocalDataSourceImpl(ref.watch(databaseProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.watch(historyLocalDataSourceProvider)),
);

final getHistoryProvider = Provider<GetHistory>(
  (ref) => GetHistory(ref.watch(historyRepositoryProvider)),
);

final saveConversionProvider = Provider<SaveConversion>(
  (ref) => SaveConversion(ref.watch(historyRepositoryProvider)),
);

final deleteConversionProvider = Provider<DeleteConversion>(
  (ref) => DeleteConversion(ref.watch(historyRepositoryProvider)),
);

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<ConversionRecord>>(
      HistoryNotifier.new,
    );

class HistoryNotifier extends AsyncNotifier<List<ConversionRecord>> {
  @override
  Future<List<ConversionRecord>> build() => ref.read(getHistoryProvider)();

  Future<void> add(ConversionRecord record) async {
    final saved = await ref.read(saveConversionProvider)(record);
    if (!ref.mounted) return;
    final current = state.value;
    if (state.hasValue && current != null) {
      state = AsyncData([saved, ...current]);
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> delete(int id) async {
    final previous = state.value ?? const [];
    state = AsyncData(previous.where((r) => r.id != id).toList());
    try {
      await ref.read(deleteConversionProvider)(id);
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous);
      rethrow;
    }
  }
}
