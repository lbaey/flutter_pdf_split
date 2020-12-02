# flutter_pdf_split

A flutter plugin to split a multipage PDF file into multiple PDF files.

## Usage

```dart
import 'package:flutter_pdf_split/flutter_pdf_split.dart';

Map<dynamic,dynamic> result = await FlutterPdfSplit.split({
  "filePath": path,
  "outDirectory": directory
});
```

`result` is a HashMap :

| key           | value                       |
| ------------- |-----------------------------|
| pageCount     | Initial PDF page count      |
| pagePaths     | Array of single pages paths |

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
