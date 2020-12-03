import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPdfSplitArgs {
  /// File path of the pdf to split
  final String filePath;

  /// Target directory to put files
  final String outDirectory;

  /// Prefix for each pdf page file, default value is 'page_'
  final String outFilePrefix;

  FlutterPdfSplitArgs(this.filePath, this.outDirectory, {this.outFilePrefix = "page_"})
      : assert(filePath != null && outDirectory != null);

  Map get toMap => {
        "filePath": filePath,
        "outDirectory": outDirectory,
        "outFileNamePrefix": outFilePrefix,
      };
}

class FlutterPdfSplitResult {
  int pageCount;
  List<String> pagePaths;

  FlutterPdfSplitResult(Map result)
      : assert(result.containsKey("pageCount") &&
            result.containsKey("pagePaths") &&
            result["pagePaths"] is List) {
    this.pageCount = result["pageCount"];
    this.pagePaths = List<String>();
    (result["pagePaths"] as List).forEach((path) {
      if (path is String) this.pagePaths.add(path);
    });
  }
}

class FlutterPdfSplit {
  static const MethodChannel _channel =
      const MethodChannel('flutter_pdf_split');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<FlutterPdfSplitResult> split(FlutterPdfSplitArgs args) async {
    // TODO verify args keys
    return _split(args);
  }

  /// Splits PDF file [value] and returns the page count.
  static Future<FlutterPdfSplitResult> _split(FlutterPdfSplitArgs args) async {
    Map<dynamic, dynamic> result =
        await _channel.invokeMethod('split', args.toMap);
    return FlutterPdfSplitResult(result);
  }
}
