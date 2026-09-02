import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Log centralizado do app.
///
/// Substitui os `print` espalhados pelos serviços: em debug o texto continua
/// visível no console, e em release o problema chega ao Sentry em vez de se
/// perder no logcat.
void logError(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'BibleWise',
    error: error,
    stackTrace: stackTrace,
    level: 1000,
  );

  if (kDebugMode) return;

  if (error != null) {
    Sentry.captureException(error, stackTrace: stackTrace);
  } else {
    Sentry.captureMessage(message, level: SentryLevel.error);
  }
}

void logInfo(String message) {
  developer.log(message, name: 'BibleWise');
}
