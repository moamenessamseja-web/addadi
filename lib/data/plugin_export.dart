import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../domain/csv_export.dart';

/// Writes the file to the app's temporary (cache) directory and opens the Android share sheet.
class PluginExportSink implements ExportSink {
  const PluginExportSink();

  @override
  Future<void> shareFile({required String filename, required String content, required String mimeType}) async {
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsString(content, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)], subject: filename),
    );
  }
}
