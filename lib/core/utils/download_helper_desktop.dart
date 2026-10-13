// lib/core/utils/download_helper_desktop.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> platformDownload(Uint8List bytes, String fileName) async {
  final savePath = await FilePicker.platform.saveFile(
    dialogTitle: 'Save your image',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['png'],
  );
  if (savePath == null) return;
  await File(savePath).writeAsBytes(bytes);
}
