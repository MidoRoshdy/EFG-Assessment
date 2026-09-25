import 'dart:async';

import 'package:currency_converter/core/error/failures.dart';
import 'package:currency_converter/features/converter/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/converter/domain/entities/currency.dart';
import 'package:currency_converter/features/converter/domain/repositories/converter_repository.dart';
import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';
import 'package:currency_converter/features/history/domain/repositories/history_repository.dart';

const testCurrencies = [
  Currency(code: 'EGP', name: 'Egyptian Pound'),
  Currency(code: 'EUR', name: 'Euro'),
  Currency(code: 'USD', name: 'US Dollar'),
];

class FakeConverterRepository implements ConverterRepository {
  FakeConverterRepository({
    this.rate = 0.5,
    this.rateDate,
    this.isCached = false,
    this.convertError,
    this.currenciesError,
  });

  final double rate;
  final DateTime? rateDate;
  final bool isCached;
  Failure? convertError;
  Failure? currenciesError;

  /// When set, `convert` waits for this completer before answering.
  Completer<void>? gate;

  int convertCalls = 0;

  @override
  Future<List<Currency>> getCurrencies() async {
    if (currenciesError case final error?) throw error;
    return testCurrencies;
  }

  @override
  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    convertCalls++;
    await gate?.future;
    if (convertError case final error?) throw error;
    return ConversionResult(
      from: from,
      to: to,
      amount: amount,
      rate: rate,
      date: rateDate ?? DateTime(2026, 9, 24),
      isCached: isCached,
    );
  }
}

class InMemoryHistoryRepository implements HistoryRepository {
  final List<ConversionRecord> records = [];
  bool failOnDelete = false;
  int _nextId = 1;

  @override
  Future<List<ConversionRecord>> getHistory() async =>
      records.reversed.toList();

  @override
  Future<ConversionRecord> save(ConversionRecord record) async {
    final saved = ConversionRecord(
      id: _nextId++,
      from: record.from,
      to: record.to,
      amount: record.amount,
      rate: record.rate,
      rateDate: record.rateDate,
      createdAt: record.createdAt,
      isCached: record.isCached,
    );
    records.add(saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    if (failOnDelete) throw const CacheFailure('delete failed');
    records.removeWhere((r) => r.id == id);
  }
}

ConversionRecord sampleRecord({
  int? id,
  String from = 'USD',
  String to = 'EGP',
  double amount = 1,
  double rate = 48,
  bool isCached = false,
}) => ConversionRecord(
  id: id,
  from: from,
  to: to,
  amount: amount,
  rate: rate,
  rateDate: DateTime(2026, 9, 24),
  createdAt: DateTime(2026, 9, 25, 10, 30),
  isCached: isCached,
);
