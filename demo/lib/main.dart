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

import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_harfbuzz/pdf_harfbuzz.dart';
import 'app.dart';

void main() {
  try {
    final shaper = HarfBuzzShaper();
    pw.HarfBuzzText.defaultShaper = shaper.shape;
    print('HarfBuzz text shaper successfully initialized.');
  } catch (e) {
    print('Failed to initialize HarfBuzz text shaper: $e');
  }
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollbarTheme = ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
    );

    return MaterialApp(
      theme: ThemeData.light().copyWith(scrollbarTheme: scrollbarTheme),
      darkTheme: ThemeData.dark().copyWith(scrollbarTheme: scrollbarTheme),
      title: 'Flutter PDF Demo',
      home: const MyApp(),
    );
  }
}
