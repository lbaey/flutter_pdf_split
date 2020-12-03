# flutter_pdf_split

A flutter plugin to split a multipage PDF file into multiple PDF files.

## Usage

```dart
import 'package:flutter_pdf_split/flutter_pdf_split.dart';

FlutterPdfSplitResult splitResult = await FlutterPdfSplit.split(
    FlutterPdfSplitArgs(filePath, _outDirectory),
);
```

The multiple page pdf from 'filePath' will be split into multiple pdf (one for each page) into the directory '_outDirectory'.

