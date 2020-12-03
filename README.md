# flutter_pdf_split

A flutter plugin to split a multipage PDF file into multiple PDF files.

## Usage

```dart
import 'package:flutter_pdf_split/flutter_pdf_split.dart';

FlutterPdfSplitResult splitResult = await FlutterPdfSplit.split(FlutterPdfSplitArgs(filePath, _outDirectory));
```

