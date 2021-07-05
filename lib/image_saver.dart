// ignore:avoid_web_libraries_in_flutter
import 'dart:async';

import 'dart:typed_data';
import 'package:js/js.dart';

// ignore: missing_js_lib_annotation
@JS()
external void _exportRaw(String key, Uint8List value);

class ImageSaver {
  static Future<String> save(String name, Uint8List fileData) async {
    _exportRaw(name, fileData);
    return name;
  }
}
