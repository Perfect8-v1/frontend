// lib/services/pdf_service_stub.dart
// Stub for non-web platforms (native uses Printing package directly)
import 'dart:typed_data';

/// Stub - not used on native platforms (they use Printing.layoutPdf instead)
void downloadPdf(Uint8List bytes, String filename) {
  // This should never be called on native platforms
  throw UnsupportedError('downloadPdf is only supported on web');
}
