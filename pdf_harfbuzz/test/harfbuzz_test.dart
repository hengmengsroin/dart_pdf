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

import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_harfbuzz/pdf_harfbuzz.dart';

void main() {
  test('HarfBuzz text shaping test', () async {
    final shaper = HarfBuzzShaper();

    final client = HttpClient();
    final url = Uri.parse(
      'https://raw.githubusercontent.com/notofonts/noto-fonts/main/hinted/ttf/NotoSansKhmer/NotoSansKhmer-Regular.ttf',
    );
    final request = await client.getUrl(url);
    final response = await request.close();
    final fontBytes = await response.fold<BytesBuilder>(
      BytesBuilder(),
      (b, d) => b..add(d),
    );
    final fontData = fontBytes.takeBytes().buffer.asByteData();
    client.close();

    final run = shaper.shape("សួស្តីខ្ញុំជាអ្នកណាតើច្បាប់", fontData);

    expect(run.glyphs, isNotEmpty);
    print('Shaped glyphs:');
    for (final g in run.glyphs) {
      print(
        '  Glyph ID: ${g.glyphId}, cluster: ${g.cluster}, xAdvance: ${g.xAdvance}, xOffset: ${g.xOffset}, yOffset: ${g.yOffset}',
      );
    }

    final pdf = pw.Document();

    pw.HarfBuzzText.defaultShaper = shaper.shape;

    final font = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.HarfBuzzText(
          "សួស្តីខ្ញុំជាអ្នកណាតើច្បាប់",
          font: font,
          fontSize: 24,
        ),
      ),
    );

    final pdfBytes = await pdf.save();
    final file = File('khmer_shaped_test.pdf');
    await file.writeAsBytes(pdfBytes);
    print('PDF saved to: ${file.absolute.path}');

    expect(await file.exists(), isTrue);

    shaper.dispose();
  });

  test('HarfBuzzText line wrapping test', () async {
    final shaper = HarfBuzzShaper();

    final client = HttpClient();
    final url = Uri.parse(
      'https://raw.githubusercontent.com/notofonts/noto-fonts/main/hinted/ttf/NotoSansKhmer/NotoSansKhmer-Regular.ttf',
    );
    final request = await client.getUrl(url);
    final response = await request.close();
    final fontBytes = await response.fold<BytesBuilder>(
      BytesBuilder(),
      (b, d) => b..add(d),
    );
    final fontData = fontBytes.takeBytes().buffer.asByteData();
    client.close();

    pw.HarfBuzzText.defaultShaper = shaper.shape;
    final font = pw.Font.ttf(fontData);

    final widget = pw.HarfBuzzText(
      "ភាសាខ្មែរគឺជាភាសាផ្លូវការនៃប្រទេសកម្ពុជា",
      font: font,
      fontSize: 24,
    );

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.SizedBox(
            width: 200,
            child: widget,
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final file = File('khmer_wrap_test.pdf');
    await file.writeAsBytes(pdfBytes);
    print('Wrap PDF saved to: ${file.absolute.path}');

    expect(await file.exists(), isTrue);

    shaper.dispose();
  });
}
