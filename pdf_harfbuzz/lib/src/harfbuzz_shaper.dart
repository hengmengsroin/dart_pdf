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

import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:pdf/pdf.dart';
import 'harfbuzz_bindings.dart';

class HarfBuzzShaper {
  HarfBuzzShaper() : bindings = HarfBuzzBindings();

  final HarfBuzzBindings bindings;

  // Cache compiled fonts to optimize performance
  final _fontCache = <ByteData, _CachedFont>{};

  ShapedRun shape(String text, ByteData fontData) {
    final cached = _fontCache.putIfAbsent(fontData, () {
      final bytes = fontData.buffer.asUint8List(
        fontData.offsetInBytes,
        fontData.lengthInBytes,
      );
      final pointer = malloc<ffi.Char>(bytes.length);
      final byteData = pointer.cast<ffi.Uint8>().asTypedList(bytes.length);
      byteData.setAll(0, bytes);

      final blob = bindings.hb_blob_create(
        pointer,
        bytes.length,
        HB_MEMORY_MODE_READONLY,
        ffi.nullptr,
        ffi.nullptr,
      );

      final face = bindings.hb_face_create(blob, 0);
      final font = bindings.hb_font_create(face);

      // Keep coordinates in design units
      final upem = bindings.hb_face_get_upem(face);
      bindings.hb_font_set_scale(font, upem, upem);

      return _CachedFont(blob, face, font, pointer);
    });

    final buffer = bindings.hb_buffer_create();

    final units = utf8.encode(text);
    final textPtr = malloc<ffi.Char>(units.length);
    final textList = textPtr.cast<ffi.Uint8>().asTypedList(units.length);
    textList.setAll(0, units);

    bindings.hb_buffer_add_utf8(buffer, textPtr, units.length, 0, units.length);
    bindings.hb_buffer_guess_segment_properties(buffer);
    bindings.hb_shape(cached.font, buffer, ffi.nullptr, 0);

    final len = bindings.hb_buffer_get_length(buffer);
    final infoPtr = bindings.hb_buffer_get_glyph_infos(buffer, ffi.nullptr);
    final posPtr = bindings.hb_buffer_get_glyph_positions(buffer, ffi.nullptr);

    final glyphs = <ShapedGlyph>[];
    for (var i = 0; i < len; i++) {
      final info = infoPtr[i];
      final pos = posPtr[i];

      // Convert UTF-8 byte cluster index to Dart UTF-16 character index
      var utf16Cluster = 0;
      var byteCount = 0;
      for (var c = 0; c < text.length; c++) {
        if (byteCount >= info.cluster) {
          utf16Cluster = c;
          break;
        }
        final codeUnit = text.codeUnitAt(c);
        if (codeUnit >= 0xd800 && codeUnit <= 0xdbff) {
          byteCount += 4;
          c++;
        } else if (codeUnit >= 0x0800) {
          byteCount += 3;
        } else if (codeUnit >= 0x0080) {
          byteCount += 2;
        } else {
          byteCount += 1;
        }
      }
      if (byteCount < info.cluster) {
        utf16Cluster = text.length;
      }

      glyphs.add(
        ShapedGlyph(
          glyphId: info.codepoint,
          cluster: utf16Cluster,
          xAdvance: pos.xAdvance.toDouble(),
          yAdvance: pos.yAdvance.toDouble(),
          xOffset: pos.xOffset.toDouble(),
          yOffset: pos.yOffset.toDouble(),
        ),
      );
    }

    malloc.free(textPtr);
    bindings.hb_buffer_destroy(buffer);

    return ShapedRun(glyphs: glyphs);
  }

  void dispose() {
    for (final cached in _fontCache.values) {
      bindings.hb_font_destroy(cached.font);
      bindings.hb_face_destroy(cached.face);
      bindings.hb_blob_destroy(cached.blob);
      malloc.free(cached.dataPointer);
    }
    _fontCache.clear();
  }
}

class _CachedFont {
  _CachedFont(this.blob, this.face, this.font, this.dataPointer);
  final ffi.Pointer<ffi.Opaque> blob;
  final ffi.Pointer<ffi.Opaque> face;
  final ffi.Pointer<ffi.Opaque> font;
  final ffi.Pointer<ffi.Char> dataPointer;
}
