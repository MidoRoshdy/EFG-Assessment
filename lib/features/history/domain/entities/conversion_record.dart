class ConversionRecord {
  const ConversionRecord({
    this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.rate,
    required this.rateDate,
    required this.createdAt,
    this.isCached = false,
  });

  final int? id;
  final String from;
  final String to;
  final double amount;
  final double rate;
  final DateTime rateDate;
  final DateTime createdAt;

  final bool isCached;

  double get convertedAmount => amount * rate;

  double get inverseRate => rate == 0 ? 0 : 1 / rate;
}
