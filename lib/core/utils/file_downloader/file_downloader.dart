import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart';

Future<void> downloadFile({
  required String content,
  required String fileName,
  String mimeType = 'text/csv;charset=utf-8',
}) {
  return saveAndDownload(
    content: content,
    fileName: fileName,
    mimeType: mimeType,
  );
}
