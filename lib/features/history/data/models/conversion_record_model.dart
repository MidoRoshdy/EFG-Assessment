import 'package:currency_converter/features/history/domain/entities/conversion_record.dart';

class ConversionRecordModel extends ConversionRecord {
  const ConversionRecordModel({
    super.id,
    required super.from,
    required super.to,
    required super.amount,
    required super.rate,
    required super.rateDate,
    required super.createdAt,
    super.isCached,
  });

  factory ConversionRecordModel.fromEntity(ConversionRecord e) {
    return ConversionRecordModel(
      id: e.id,
      from: e.from,
      to: e.to,
      amount: e.amount,
      rate: e.rate,
      rateDate: e.rateDate,
      createdAt: e.createdAt,
      isCached: e.isCached,
    );
  }

  factory ConversionRecordModel.fromMap(Map<String, Object?> map) {
    return ConversionRecordModel(
      id: map['id'] as int,
      from: map['from_currency'] as String,
      to: map['to_currency'] as String,
      amount: (map['amount'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      rateDate: DateTime.parse(map['rate_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isCached: (map['is_cached'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'from_currency': from,
    'to_currency': to,
    'amount': amount,
    'rate': rate,
    'rate_date': rateDate.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'is_cached': isCached ? 1 : 0,
  };

  ConversionRecordModel copyWithId(int id) => ConversionRecordModel(
    id: id,
    from: from,
    to: to,
    amount: amount,
    rate: rate,
    rateDate: rateDate,
    createdAt: createdAt,
    isCached: isCached,
  );
}
