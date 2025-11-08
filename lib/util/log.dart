import 'package:flutter/foundation.dart';

/// Simple debug logging helper. Wraps prints so analyzer avoid_print is satisfied.
void logDebug(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}
