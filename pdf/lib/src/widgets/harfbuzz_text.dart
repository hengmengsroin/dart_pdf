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

import '../../pdf.dart';
import 'font.dart';
import 'geometry.dart';
import 'widget.dart';

class HarfBuzzText extends Widget {
  HarfBuzzText(
    this.text, {
    required this.font,
    this.fontSize = 12.0,
    this.color,
    this.shaper,
  });

  final String text;
  final Font font;
  final double fontSize;
  final PdfColor? color;
  final TextShaper? shaper;

  static TextShaper? defaultShaper;

  List<ShapedGlyph>? _shapedGlyphs;

  @override
  void layout(
    Context context,
    BoxConstraints constraints, {
    bool parentUsesSize = false,
  }) {
    final activeShaper = shaper ?? defaultShaper;
    if (activeShaper == null) {
      throw StateError(
        'No TextShaper provided for HarfBuzzText. '
        'Provide a shaper parameter or set HarfBuzzText.defaultShaper.',
      );
    }

    if (font is! TtfFont) {
      throw ArgumentError('HarfBuzzText requires a TrueType Font (TtfFont).');
    }

    final ttfFont = font as TtfFont;
    final run = activeShaper(text, ttfFont.data);
    _shapedGlyphs = run.glyphs;

    // Calculate width by summing glyph advances (in font units)
    var totalAdvance = 0.0;
    for (final glyph in run.glyphs) {
      totalAdvance += glyph.xAdvance;
    }

    final fontScale = fontSize / font.getFont(context).unitsPerEm;
    final width = totalAdvance * fontScale;
    final height =
        (font.getFont(context).ascent - font.getFont(context).descent) *
        fontSize;

    box = PdfRect(
      0,
      0,
      constraints.constrainWidth(width),
      constraints.constrainHeight(height),
    );
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (_shapedGlyphs == null || _shapedGlyphs!.isEmpty) {
      return;
    }

    final pdfFont = font.getFont(context);
    final paintColor = color ?? PdfColors.black;

    context.canvas.setFillColor(paintColor);

    // Draw the shaped glyphs
    // The baseline y-coordinate is box.bottom + descent * fontSize
    final baselineY = box!.bottom - pdfFont.descent * fontSize;

    context.canvas.drawShapedGlyphs(
      pdfFont,
      fontSize,
      _shapedGlyphs!,
      text,
      box!.left,
      baselineY,
    );
  }
}
