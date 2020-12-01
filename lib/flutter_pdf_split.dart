import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPdfSplit {
  static const MethodChannel _channel =
      const MethodChannel('flutter_pdf_split');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> split(String filePath) async {
    return _split(filePath);
  }

  /// Splits PDF file [value] and returns the page count.
  static Future<int> _split(String filePath) async {
    int pages = await _channel.invokeMethod('split', {"path": filePath});
    return pages;
  }
}
