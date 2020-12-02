import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pdf_split/flutter_pdf_split.dart';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _pageCount = 0;
  List<dynamic> _pagePaths = new List();
  String _outDirectory;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    askPermission();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPdfSplit.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> askPermission() async {
    await Permission.storage.request();
  }

  void _openFileExplorer() async {

    // the output directory must be chosen first
    if (_outDirectory == null) {
      return;
    }

    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);

      Map<dynamic,dynamic> splitResult = await FlutterPdfSplit.split(
          {"filePath": file.path, "outDirectory": _outDirectory}
      );

      print(splitResult);

      setState(() {
        _pageCount = splitResult["pageCount"];
        _pagePaths = splitResult["pagePaths"];
      });
    } else {
      // User canceled the picker
    }
  }

  void _openDirectoryExplorer() async {
    String directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      print(directory);

      setState(() {
        _outDirectory = directory;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
              children: [
                Text('Running on: $_platformVersion\n'),
                RaisedButton(
                  onPressed: () => _openDirectoryExplorer(),
                  child: Text("Choose output directory"),
                ),
                RaisedButton(
                  onPressed: () => _openFileExplorer(),
                  child: Text("Choose input PDF file"),
                ),
                Text('Splitted pdf: $_pageCount pages\n'),
                _pagePaths.isNotEmpty
                ?
                Flexible(child: ListView.builder(
                  itemCount: _pageCount,
                  itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 30,
                        child: Center(
                            child: Text(_pagePaths[index])
                        ),
                      );

                  }
                ))
                :
                Text("Select a file")
              ]
            )
        ),
      ),
    );
  }
}
