import 'package:currency_converter/features/converter/domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({required super.code, required super.name});

  static List<CurrencyModel> fromJsonMap(Map<String, dynamic> json) {
    return json.entries
        .map((e) => CurrencyModel(code: e.key, name: e.value as String))
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }
}
