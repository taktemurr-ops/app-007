/// Converts common international decimal digits without guessing thousands
/// separators. Arabic decimal marks and decimal commas are supported.
double? parseMacroNumber(String input, {double minimum = 0, double maximum = 10000}) {
  var source = input.trim();
  if (source.isEmpty || source.length > 48) return null;
  final out = StringBuffer();
  for (final rune in source.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      out.writeCharCode(rune);
    } else if (rune >= 0x660 && rune <= 0x669) {
      out.writeCharCode(rune - 0x660 + 48);
    } else if (rune >= 0x6f0 && rune <= 0x6f9) {
      out.writeCharCode(rune - 0x6f0 + 48);
    } else if (rune == 0x2e || rune == 0x2c || rune == 0x66b) {
      out.write('.');
    } else {
      return null;
    }
  }
  final normalized = out.toString();
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) return null;
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || value < minimum || value > maximum) return null;
  return value;
}

int? parseMacroWholeNumber(String input, {int minimum = 0, int maximum = 10000}) {
  final result = parseMacroNumber(input, minimum: minimum.toDouble(), maximum: maximum.toDouble());
  return result == null || result != result.truncateToDouble() ? null : result.toInt();
}
