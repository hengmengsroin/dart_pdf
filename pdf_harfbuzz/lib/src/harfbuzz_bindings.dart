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

import 'dart:ffi' as ffi;
import 'dart:io';

// Structs matching HarfBuzz C structs
final class HbGlyphInfo extends ffi.Struct {
  @ffi.Uint32()
  external int codepoint;
  @ffi.Uint32()
  external int mask;
  @ffi.Uint32()
  external int cluster;
  @ffi.Uint32()
  external int var1;
  @ffi.Uint32()
  external int var2;
}

final class HbGlyphPosition extends ffi.Struct {
  @ffi.Int32()
  external int xAdvance;
  @ffi.Int32()
  external int yAdvance;
  @ffi.Int32()
  external int xOffset;
  @ffi.Int32()
  external int yOffset;
  @ffi.Uint32()
  external int var1;
}

// Memory modes
const int HB_MEMORY_MODE_READONLY = 1;

class HarfBuzzBindings {
  HarfBuzzBindings() {
    final dylib = _loadHarfBuzz();

    hb_blob_create = dylib.lookupFunction<
        ffi.Pointer<ffi.Opaque> Function(
            ffi.Pointer<ffi.Char>,
            ffi.Uint32,
            ffi.Int32,
            ffi.Pointer<ffi.Void>,
            ffi.Pointer<ffi.Void>),
        ffi.Pointer<ffi.Opaque> Function(
            ffi.Pointer<ffi.Char>,
            int,
            int,
            ffi.Pointer<ffi.Void>,
            ffi.Pointer<ffi.Void>)>('hb_blob_create');

    hb_blob_destroy = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>),
        void Function(ffi.Pointer<ffi.Opaque>)>('hb_blob_destroy');

    hb_face_create = dylib.lookupFunction<
        ffi.Pointer<ffi.Opaque> Function(ffi.Pointer<ffi.Opaque>, ffi.Uint32),
        ffi.Pointer<ffi.Opaque> Function(
            ffi.Pointer<ffi.Opaque>, int)>('hb_face_create');

    hb_face_destroy = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>),
        void Function(ffi.Pointer<ffi.Opaque>)>('hb_face_destroy');

    hb_font_create = dylib.lookupFunction<
        ffi.Pointer<ffi.Opaque> Function(ffi.Pointer<ffi.Opaque>),
        ffi.Pointer<ffi.Opaque> Function(ffi.Pointer<ffi.Opaque>)>('hb_font_create');

    hb_font_destroy = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>),
        void Function(ffi.Pointer<ffi.Opaque>)>('hb_font_destroy');

    hb_font_set_scale = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>, ffi.Int32, ffi.Int32),
        void Function(ffi.Pointer<ffi.Opaque>, int, int)>('hb_font_set_scale');

    hb_buffer_create = dylib.lookupFunction<
        ffi.Pointer<ffi.Opaque> Function(),
        ffi.Pointer<ffi.Opaque> Function()>('hb_buffer_create');

    hb_buffer_destroy = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>),
        void Function(ffi.Pointer<ffi.Opaque>)>('hb_buffer_destroy');

    hb_buffer_add_utf8 = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Char>,
            ffi.Int32, ffi.Uint32, ffi.Int32),
        void Function(ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Char>, int, int,
            int)>('hb_buffer_add_utf8');

    hb_buffer_guess_segment_properties = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>),
        void Function(ffi.Pointer<ffi.Opaque>)>('hb_buffer_guess_segment_properties');

    hb_shape = dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Opaque>,
            ffi.Pointer<ffi.Void>, ffi.Uint32),
        void Function(ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Opaque>,
            ffi.Pointer<ffi.Void>, int)>('hb_shape');

    hb_buffer_get_length = dylib.lookupFunction<
        ffi.Uint32 Function(ffi.Pointer<ffi.Opaque>),
        int Function(ffi.Pointer<ffi.Opaque>)>('hb_buffer_get_length');

    hb_buffer_get_glyph_infos = dylib.lookupFunction<
        ffi.Pointer<HbGlyphInfo> Function(
            ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Uint32>),
        ffi.Pointer<HbGlyphInfo> Function(
            ffi.Pointer<ffi.Opaque>,
            ffi.Pointer<ffi.Uint32>)>('hb_buffer_get_glyph_infos');

    hb_buffer_get_glyph_positions = dylib.lookupFunction<
        ffi.Pointer<HbGlyphPosition> Function(
            ffi.Pointer<ffi.Opaque>, ffi.Pointer<ffi.Uint32>),
        ffi.Pointer<HbGlyphPosition> Function(
            ffi.Pointer<ffi.Opaque>,
            ffi.Pointer<ffi.Uint32>)>('hb_buffer_get_glyph_positions');
  }

  late final ffi.Pointer<ffi.Opaque> Function(
          ffi.Pointer<ffi.Char> data,
          int length,
          int mode,
          ffi.Pointer<ffi.Void> userData,
          ffi.Pointer<ffi.Void> destroyFunc)
      hb_blob_create;

  late final void Function(ffi.Pointer<ffi.Opaque> blob) hb_blob_destroy;

  late final ffi.Pointer<ffi.Opaque> Function(
      ffi.Pointer<ffi.Opaque> blob, int index) hb_face_create;

  late final void Function(ffi.Pointer<ffi.Opaque> face) hb_face_destroy;

  late final ffi.Pointer<ffi.Opaque> Function(ffi.Pointer<ffi.Opaque> face)
      hb_font_create;

  late final void Function(ffi.Pointer<ffi.Opaque> font) hb_font_destroy;

  late final void Function(ffi.Pointer<ffi.Opaque> font, int xScale, int yScale)
      hb_font_set_scale;

  late final ffi.Pointer<ffi.Opaque> Function() hb_buffer_create;

  late final void Function(ffi.Pointer<ffi.Opaque> buffer) hb_buffer_destroy;

  late final void Function(
      ffi.Pointer<ffi.Opaque> buffer,
      ffi.Pointer<ffi.Char> text,
      int textLength,
      int itemOffset,
      int itemLength) hb_buffer_add_utf8;

  late final void Function(ffi.Pointer<ffi.Opaque> buffer)
      hb_buffer_guess_segment_properties;

  late final void Function(
      ffi.Pointer<ffi.Opaque> font,
      ffi.Pointer<ffi.Opaque> buffer,
      ffi.Pointer<ffi.Void> features,
      int numFeatures) hb_shape;

  late final int Function(ffi.Pointer<ffi.Opaque> buffer) hb_buffer_get_length;

  late final ffi.Pointer<HbGlyphInfo> Function(
          ffi.Pointer<ffi.Opaque> buffer, ffi.Pointer<ffi.Uint32> length)
      hb_buffer_get_glyph_infos;

  late final ffi.Pointer<HbGlyphPosition> Function(
          ffi.Pointer<ffi.Opaque> buffer, ffi.Pointer<ffi.Uint32> length)
      hb_buffer_get_glyph_positions;

  ffi.DynamicLibrary _loadHarfBuzz() {
    if (Platform.isMacOS) {
      for (final path in [
        'libharfbuzz.0.dylib',
        'libharfbuzz.dylib',
        '/opt/homebrew/lib/libharfbuzz.dylib',
        '/usr/local/lib/libharfbuzz.dylib',
      ]) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (_) {}
      }
    } else if (Platform.isLinux) {
      for (final path in [
        'libharfbuzz.so.0',
        'libharfbuzz.so',
        'libharfbuzz.so.0.30000.0',
      ]) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (_) {}
      }
    } else if (Platform.isWindows) {
      for (final path in [
        'libharfbuzz-0.dll',
        'harfbuzz.dll',
      ]) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (_) {}
      }
    }
    try {
      return ffi.DynamicLibrary.process();
    } catch (_) {}
    throw StateError(
        'Could not load HarfBuzz dynamic library. Please make sure libharfbuzz is installed on the system.');
  }
}
