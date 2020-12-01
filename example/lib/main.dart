import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pdf_split/flutter_pdf_split.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _pageCount;
  List<PlatformFile> _paths;
  String _fileName;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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

  void _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);

      int pageCount = await FlutterPdfSplit.split(file.path);

      setState(() {
        _pageCount = pageCount;
      });
    } else {
      // User canceled the picker
    }

    // try {
    //   _paths = (await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //     allowedExtensions: ['pdf'],
    //   ))
    //       ?.files;
    // } on PlatformException catch (e) {
    //   print("Unsupported operation" + e.toString());
    // } catch (ex) {
    //   print(ex);
    // }
    // if (!mounted) return;
    // setState(() {
    //   //_loadingPath = false;
    //   _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    // });
  }
  // Il me faut un bouton qui récupère un chemin d'un pdf dans un répertoire ou on peut écrire
  // FlutterPdfSplit.split(filePath)

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
                onPressed: () => _openFileExplorer(),
                child: Text("Open file picker"),
              ),
              Text('Splitted pdf: $_pageCount pages\n'),
            ]
          )
        ),
      ),
    );
  }
}
