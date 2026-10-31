import 'dart:convert';
import 'dart:io';

Future<void> saveAndDownload({
  required String content,
  required String fileName,
  required String mimeType,
}) async {
  try {
    String? dirPath;
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      final home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (home != null) {
        final downloads = Directory('$home/Downloads');
        if (downloads.existsSync()) {
          dirPath = downloads.path;
        }
      }
    }
    final file = File(dirPath != null ? '$dirPath/$fileName' : fileName);
    await file.writeAsBytes(utf8.encode(content));
  } catch (_) {
    // Non-fatal fallback for restricted sandbox environments
  }
}
