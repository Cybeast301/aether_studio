// lib/core/utils/download_helper.dart
// ✅ Handles image download for both Web and Desktop

import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Conditional imports
import 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_desktop.dart';

Future<void> downloadImageFile(Uint8List bytes, String fileName) async {
  await platformDownload(bytes, fileName);
}
