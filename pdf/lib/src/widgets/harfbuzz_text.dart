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

  List<_PositionedLine>? _positionedLines;

  bool _isBreakOpportunity(String char) {
    return char == ' ' ||
        char == '\t' ||
        char == '\n' ||
        char == '\r' ||
        char == '\u200b' ||
        char == '\u200c';
  }

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
    final pdfFont = font.getFont(context);
    final fontScale = fontSize / pdfFont.unitsPerEm;
    final lineHeight = (pdfFont.ascent - pdfFont.descent) * fontSize;

    final paragraphs = text.split('\n');
    _positionedLines = [];

    double maxLineWidth = 0.0;
    double totalHeight = 0.0;

    for (final paragraph in paragraphs) {
      if (paragraph.isEmpty) {
        _positionedLines!.add(_PositionedLine(
          glyphs: [],
          yOffset: totalHeight,
          originalText: paragraph,
        ));
        totalHeight += lineHeight;
        continue;
      }

      final run = activeShaper(paragraph, ttfFont.data);
      final glyphs = run.glyphs;

      List<ShapedGlyph> currentLine = [];
      double currentWidth = 0.0;

      for (var i = 0; i < glyphs.length; i++) {
        final glyph = glyphs[i];
        final glyphWidth = glyph.xAdvance * fontScale;

        if (currentWidth + glyphWidth > constraints.maxWidth &&
            currentLine.isNotEmpty) {
          var breakIndex = -1;
          for (var j = currentLine.length - 1; j >= 0; j--) {
            final lineGlyph = currentLine[j];
            if (lineGlyph.cluster < paragraph.length) {
              final char = paragraph[lineGlyph.cluster];
              if (_isBreakOpportunity(char)) {
                breakIndex = j;
                break;
              }
            }
          }

          if (breakIndex != -1) {
            final lineGlyphs = currentLine.sublist(0, breakIndex + 1);
            _positionedLines!.add(_PositionedLine(
              glyphs: lineGlyphs,
              yOffset: totalHeight,
              originalText: paragraph,
            ));
            totalHeight += lineHeight;

            double lineW = 0.0;
            for (final lg in lineGlyphs) {
              lineW += lg.xAdvance * fontScale;
            }
            if (lineW > maxLineWidth) {
              maxLineWidth = lineW;
            }

            final remaining = currentLine.sublist(breakIndex + 1);
            currentLine = List.from(remaining);
            currentWidth = 0.0;
            for (final rg in currentLine) {
              currentWidth += rg.xAdvance * fontScale;
            }
          } else {
            _positionedLines!.add(_PositionedLine(
              glyphs: currentLine,
              yOffset: totalHeight,
              originalText: paragraph,
            ));
            totalHeight += lineHeight;

            if (currentWidth > maxLineWidth) {
              maxLineWidth = currentWidth;
            }

            currentLine = [];
            currentWidth = 0.0;
          }
        }

        currentLine.add(glyph);
        currentWidth += glyphWidth;
      }

      if (currentLine.isNotEmpty) {
        _positionedLines!.add(_PositionedLine(
          glyphs: currentLine,
          yOffset: totalHeight,
          originalText: paragraph,
        ));
        totalHeight += lineHeight;

        if (currentWidth > maxLineWidth) {
          maxLineWidth = currentWidth;
        }
      }
    }

    box = PdfRect(
      0,
      0,
      constraints.constrainWidth(maxLineWidth),
      constraints.constrainHeight(totalHeight),
    );
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (_positionedLines == null || _positionedLines!.isEmpty) {
      return;
    }

    final pdfFont = font.getFont(context);
    final paintColor = color ?? PdfColors.black;

    context.canvas.setFillColor(paintColor);

    final startBaselineY = box!.top - pdfFont.ascent * fontSize;

    for (final line in _positionedLines!) {
      if (line.glyphs.isEmpty) {
        continue;
      }

      final baselineY = startBaselineY - line.yOffset;

      context.canvas.drawShapedGlyphs(
        pdfFont,
        fontSize,
        line.glyphs,
        line.originalText,
        box!.left,
        baselineY,
      );
    }
  }
}

class _PositionedLine {
  _PositionedLine({
    required this.glyphs,
    required this.yOffset,
    required this.originalText,
  });

  final List<ShapedGlyph> glyphs;
  final double yOffset;
  final String originalText;
}
