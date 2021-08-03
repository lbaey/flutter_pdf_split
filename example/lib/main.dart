import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_split/flutter_pdf_split.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion = 'Unknown';
  FlutterPdfSplitResult? _splitResult;
  String? _outDirectory;

  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  Future<void> androidDeviceInfo() async {
    androidInfo = await deviceInfo.androidInfo;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      androidDeviceInfo().whenComplete(() {
        initPlatformState();
        askPermission();
        return null;
      });
    }
  }

  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPdfSplit.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (mounted) setState(() => _platformVersion = platformVersion);
  }

  Future<void> askPermission() async {
    if (androidInfo != null) {
      if (androidInfo!.version.sdkInt! >= 30 && Platform.isAndroid) {
        await Permission.manageExternalStorage.request();
      } else if (androidInfo!.version.sdkInt! < 30 && Platform.isAndroid) {
        await Permission.storage.request();
      }
    }
  }

  void _openFileExplorer() async {
    // the output directory must be chosen first
    if (_outDirectory == null) {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      debugPrint(file.name);
      debugPrint(file.bytes.toString());
      debugPrint(file.size.toString());
      debugPrint(file.extension);
      debugPrint(file.path);

      FlutterPdfSplitResult splitResult = await FlutterPdfSplit.split(
        FlutterPdfSplitArgs(file.path!, _outDirectory!, outFilePrefix: "Test"),
      );

      debugPrint(splitResult.toString());

      if (mounted) setState(() => _splitResult = splitResult);
    } else {
      // User canceled the picker
    }
  }

  void _openDirectoryExplorer() async {
    String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      debugPrint(directory);
      setState(() => _outDirectory = directory);
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('Running on: $_platformVersion'),
                  ),
                  ElevatedButton(
                    onPressed: _openDirectoryExplorer,
                    child: Text("Choose output directory"),
                  ),
                  ElevatedButton(
                    onPressed: _outDirectory == null ? null : _openFileExplorer,
                    child: Text("Choose input PDF file"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(_outDirectory == null
                        ? "Select directory"
                        : (_splitResult?.pageCount == null
                            ? "Select a file"
                            : 'Splitted pdf: ${_splitResult?.pageCount ?? 0} pages')),
                  ),
                  for (String path in _splitResult?.pagePaths ?? []) Text(path)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
