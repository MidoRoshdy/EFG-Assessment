abstract final class DateFormatter {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static String date(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  static String dateTime(DateTime d) {
    final local = d.toLocal();
    return '${date(local)} ${_two(local.hour)}:${_two(local.minute)}';
  }
}
