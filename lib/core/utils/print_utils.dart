import 'dart:convert';

class PrintUtils {
  // Pretty print with optional label
  static void printJson(dynamic data, {String? label}) {
    if (label != null) {
      print(label);
    }
    
    const encoder = JsonEncoder.withIndent('  ');
    try {
      final prettyString = encoder.convert(data);
      print(prettyString);
    } catch (e) {
      // If it's not JSON-encodable, just print it as-is
      print(data);
    }
    print(''); // Empty line for readability
  }
}