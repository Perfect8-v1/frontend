// lib/services/pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_models.dart';

/// Service för att generera fakturor och plocklistor.
/// Inga stub-filer behövs - vi hanterar plattformar internt.
class PdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void> _loadFonts() async {
    _regularFont ??= await PdfGoogleFonts.openSansRegular();
    _boldFont ??= await PdfGoogleFonts.openSansBold();
  }

  static pw.ThemeData _getTheme() {
    return pw.ThemeData.withFont(
      base: _regularFont,
      bold: _boldFont,
    );
  }

  /// Generera Faktura PDF
  static Future<Uint8List> generateInvoice(Order order) async {
    await _loadFonts();
    final pdf = pw.Document(theme: _getTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(order),
            pw.SizedBox(height: 30),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _buildCustomerInfo(order)),
                pw.Expanded(child: _buildInvoiceInfo(order)),
              ],
            ),
            pw.SizedBox(height: 30),
            _buildItemsTable(order),
            pw.SizedBox(height: 20),
            _buildTotals(order),
            pw.Spacer(),
            _buildInvoiceFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Skriv ut eller spara (Plattformsberoende)
  static Future<void> printInvoice(Order order) async {
    final pdfBytes = await generateInvoice(order);
    final filename = 'Faktura_${order.orderNumber}.pdf';

    if (kIsWeb) {
      // Om du någon gång kör webb, använder vi Printing-paketets inbyggda share
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    } else {
      // För Windows/Android: Öppna systemets utskriftsdialog direkt
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: filename,
      );
    }
  }

  // --- Helpers (Samma som tidigare men samlade här) ---

  static pw.Widget _buildInvoiceHeader(Order order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Perfect8',
            style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('FAKTURA',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text(order.orderNumber),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Order order) {
    final addr = order.billingAddress;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('FAKTURAADRESS',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.grey600)),
        pw.SizedBox(height: 5),
        pw.Text('${addr.firstName} ${addr.lastName}'),
        pw.Text(addr.street),
        pw.Text('${addr.postalCode} ${addr.city}'),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Order order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
            'Datum: ${order.createdDate.toIso8601String().substring(0, 10)}'),
        pw.Text('Betalningsvillkor: 14 dagar'),
        pw.Text('Betalsätt: ${order.paymentMethod}'),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Order order) {
    return pw.TableHelper.fromTextArray(
      border: null,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerHeight: 25,
      cellHeight: 20,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headers: ['Produkt', 'Antal', 'á pris', 'Summa'],
      data: order.items
          .map((item) => [
                item.productName,
                '${item.quantity}',
                '${item.unitPrice.round()} kr',
                '${item.subtotal.round()} kr',
              ])
          .toList(),
    );
  }

  static pw.Widget _buildTotals(Order order) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        children: [
          pw.Text('Delsumma: ${order.subtotal.round()} kr'),
          pw.Divider(color: PdfColors.grey400),
          pw.Text('TOTALT: ${order.total.round()} kr',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceFooter() {
    return pw.Text('Perfect8 AB | Org.nr: 559XXX-XXXX | info@perfect8.se',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600));
  }
}
