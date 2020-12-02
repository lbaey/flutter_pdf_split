import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPdfSplit {
  static const MethodChannel _channel =
      const MethodChannel('flutter_pdf_split');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map<dynamic,dynamic>> split(Map<String, String> args) async {
    // TODO verify args keys
    return _split(args);
  }

  /// Splits PDF file [value] and returns the page count.
  static Future<Map<dynamic,dynamic>> _split(Map<String, String> args) async {
    Map<dynamic,dynamic> result = await _channel.invokeMethod('split', {
      "filePath": args["filePath"],
      "outDirectory": args["outDirectory"]
    });
    return result;
  }
}
