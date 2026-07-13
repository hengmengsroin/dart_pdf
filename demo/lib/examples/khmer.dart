/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data.dart';

Future<Uint8List> generateKhmer(
  PdfPageFormat format,
  CustomData data,
) async {
  final doc = pw.Document();

  final font = await PdfGoogleFonts.chenlaRegular();

  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                text: 'HarfBuzz Complex Text Shaping (Khmer)',
              ),
              pw.Paragraph(
                text:
                    'This page demonstrates the difference between naive character rendering and HarfBuzz text shaping for the Khmer language.',
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '1. Naive pw.Text (Unshaped, incorrect layout):',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'សួស្តីខ្ញុំជាអ្នកណាតើច្បាប់',
                style: pw.TextStyle(font: font, fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'ភាសាខ្មែរគឺជាភាសាផ្លូវការនៃប្រទេសកម្ពុជា',
                style: pw.TextStyle(font: font, fontSize: 24),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                '2. pw.HarfBuzzText (Shaped, correct layout):',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.HarfBuzzText(
                'សួស្តីខ្ញុំជាអ្នកណាតើច្បាប់',
                font: font,
                fontSize: 24,
              ),
              pw.SizedBox(height: 10),
              pw.HarfBuzzText(
                'ភាសាខ្មែរគឺជាភាសាផ្លូវការនៃប្រទេសកម្ពុជា',
                font: font,
                fontSize: 24,
              ),
            ],
          ),
        );
      },
    ),
  );

  return doc.save();
}
