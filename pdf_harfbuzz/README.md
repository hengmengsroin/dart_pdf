# pdf_harfbuzz

A companion package for [`pdf`](https://pub.dev/packages/pdf) that provides HarfBuzz text shaping for complex scripts.

This package provides a `HarfBuzzText` widget that can be used to render text using the HarfBuzz shaping engine. This is particularly useful for rendering complex scripts like Arabic, Khmer, Thai, and Indic scripts correctly in PDF documents.

## Usage

Add `pdf_harfbuzz` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  pdf_harfbuzz: ^0.1.0
```

Then you can use `HarfBuzzText` just like you would use a regular `Text` widget in `pdf`:

```dart
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_harfbuzz/pdf_harfbuzz.dart';

// ...

pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      return pw.Center(
        child: pw.HarfBuzzText(
          'សួស្តីពិភពលោក', // Khmer for "Hello World"
          style: pw.TextStyle(
            font: khmerFont,
            fontSize: 24,
          ),
        ),
      );
    },
  ),
);
```
