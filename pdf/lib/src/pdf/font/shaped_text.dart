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

class ShapedGlyph {
  const ShapedGlyph({
    required this.glyphId,
    required this.cluster,
    required this.xAdvance,
    required this.yAdvance,
    required this.xOffset,
    required this.yOffset,
  });

  final int glyphId;
  final int cluster;
  final double xAdvance;
  final double yAdvance;
  final double xOffset;
  final double yOffset;

  @override
  String toString() =>
      'ShapedGlyph(glyphId: $glyphId, cluster: $cluster, xAdvance: $xAdvance, yAdvance: $yAdvance, xOffset: $xOffset, yOffset: $yOffset)';
}

class ShapedRun {
  const ShapedRun({required this.glyphs});

  final List<ShapedGlyph> glyphs;
}

typedef TextShaper = ShapedRun Function(String text, ByteData fontData);
