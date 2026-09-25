class ConversionResult {
  const ConversionResult({
    required this.from,
    required this.to,
    required this.amount,
    required this.rate,
    required this.date,
    this.isCached = false,
  });

  final String from;
  final String to;
  final double amount;
  final double rate;
  final DateTime date;

  /// True when the rate came from the offline cache instead of the live API.
  final bool isCached;

  double get convertedAmount => amount * rate;
}
