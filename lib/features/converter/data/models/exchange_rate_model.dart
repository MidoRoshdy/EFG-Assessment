import 'dart:convert';

class ExchangeRateModel {
  const ExchangeRateModel({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      base: json['base'] as String,
      date: DateTime.parse(json['date'] as String),
      rates: _parseRates(json['rates'] as Map<String, dynamic>),
    );
  }

  factory ExchangeRateModel.fromCacheRow(Map<String, Object?> row) {
    return ExchangeRateModel(
      base: row['base'] as String,
      date: DateTime.parse(row['rate_date'] as String),
      rates: _parseRates(
        jsonDecode(row['rates'] as String) as Map<String, dynamic>,
      ),
    );
  }

  final String base;
  final DateTime date;
  final Map<String, double> rates;

  Map<String, Object?> toCacheRow(DateTime fetchedAt) => {
    'base': base,
    'rate_date': date.toIso8601String(),
    'rates': jsonEncode(rates),
    'fetched_at': fetchedAt.toIso8601String(),
  };

  /// Rate for [from] → [to] derived from this table, including cross rates
  /// when neither currency is the base.
  double? rateFor(String from, String to) {
    double? valueOf(String code) => code == base ? 1 : rates[code];
    final fromValue = valueOf(from);
    final toValue = valueOf(to);
    if (fromValue == null || toValue == null || fromValue == 0) return null;
    return toValue / fromValue;
  }

  static Map<String, double> _parseRates(Map<String, dynamic> json) =>
      json.map((key, value) => MapEntry(key, (value as num).toDouble()));
}
