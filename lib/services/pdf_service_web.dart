// lib/services/pdf_service_web.dart
// Web-specific implementation using dart:html
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Download PDF in browser by creating a blob URL and triggering download
void downloadPdf(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create anchor element and trigger download
  final anchor = html.AnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();

  // Cleanup
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
