// lib/services/pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_models.dart';

// Conditional import for web
import 'pdf_service_web.dart' if (dart.library.io) 'pdf_service_stub.dart'
    as platform;

/// Service for generating PDF documents (invoices, packing lists)
class PdfService {
  // Cache fonts for reuse
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Load fonts with Swedish character support
  static Future<void> _loadFonts() async {
    _regularFont ??= await PdfGoogleFonts.openSansRegular();
    _boldFont ??= await PdfGoogleFonts.openSansBold();
  }

  /// Get theme with proper fonts
  static pw.ThemeData _getTheme() {
    return pw.ThemeData.withFont(
      base: _regularFont,
      bold: _boldFont,
    );
  }

  /// Generate invoice PDF for an order
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
            // Header
            _buildInvoiceHeader(order),
            pw.SizedBox(height: 30),

            // Customer & Invoice info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _buildCustomerInfo(order)),
                pw.Expanded(child: _buildInvoiceInfo(order)),
              ],
            ),
            pw.SizedBox(height: 30),

            // Items table
            _buildItemsTable(order),
            pw.SizedBox(height: 20),

            // Totals
            _buildTotals(order),
            pw.Spacer(),

            // Footer
            _buildInvoiceFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Generate packing list PDF for an order
  static Future<Uint8List> generatePackingList(Order order) async {
    await _loadFonts();
    final pdf = pw.Document(theme: _getTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text(
              'PLOCKLISTA',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Order: ${order.orderNumber}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Datum: ${_formatDate(order.createdDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 30),

            // Shipping address
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LEVERANSADRESS:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}'),
                  pw.Text(order.shippingAddress.street),
                  pw.Text(
                      '${order.shippingAddress.postalCode} ${order.shippingAddress.city}'),
                  if (order.shippingAddress.phone != null)
                    pw.Text('Tel: ${order.shippingAddress.phone}'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Packing items table
            _buildPackingTable(order),
            pw.SizedBox(height: 30),

            // Checkboxes for packer
            pw.Text(
              'Kontroll:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildCheckbox('Alla produkter plockade'),
            _buildCheckbox('Produkter kontrollerade'),
            _buildCheckbox('Förpackning OK'),
            _buildCheckbox('Fraktsedel bifogad'),
            pw.SizedBox(height: 20),

            // Signature line
            pw.Row(
              children: [
                pw.Text('Packad av: '),
                pw.Container(
                  width: 150,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide()),
                  ),
                  child: pw.SizedBox(height: 20),
                ),
                pw.SizedBox(width: 20),
                pw.Text('Datum: '),
                pw.Container(
                  width: 100,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide()),
                  ),
                  child: pw.SizedBox(height: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Print or save invoice (platform-aware)
  static Future<void> printInvoice(Order order) async {
    final pdfBytes = await generateInvoice(order);
    final filename = 'Faktura_${order.orderNumber}.pdf';

    if (kIsWeb) {
      // Use web-specific download
      platform.downloadPdf(pdfBytes, filename);
    } else {
      // Use native printing dialog
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: filename,
      );
    }
  }

  /// Print or save packing list (platform-aware)
  static Future<void> printPackingList(Order order) async {
    final pdfBytes = await generatePackingList(order);
    final filename = 'Plocklista_${order.orderNumber}.pdf';

    if (kIsWeb) {
      // Use web-specific download
      platform.downloadPdf(pdfBytes, filename);
    } else {
      // Use native printing dialog
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: filename,
      );
    }
  }

  // === Private helper methods ===

  static pw.Widget _buildInvoiceHeader(Order order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Perfect8',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text('E-commerce', style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'FAKTURA',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              order.orderNumber,
              style: const pw.TextStyle(fontSize: 14),
            ),
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
        pw.Text(
          'FAKTURAADRESS',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text('${addr.firstName} ${addr.lastName}'),
        pw.Text(addr.street),
        pw.Text('${addr.postalCode} ${addr.city}'),
        pw.Text(addr.country),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Order order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _buildInfoRow('Fakturadatum:', _formatDate(order.createdDate)),
        _buildInfoRow('Ordernummer:', order.orderNumber),
        _buildInfoRow('Betalningsvillkor:', '14 dagar netto'),
        _buildInfoRow('Betalningssätt:', order.paymentMethod),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Order order) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Produkt', isHeader: true),
            _tableCell('Antal', isHeader: true, align: pw.TextAlign.center),
            _tableCell('á pris', isHeader: true, align: pw.TextAlign.right),
            _tableCell('Summa', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        // Item rows
        ...order.items.map((item) => pw.TableRow(
              children: [
                _tableCell(item.productName),
                _tableCell('${item.quantity}', align: pw.TextAlign.center),
                _tableCell('${item.unitPrice.round()} kr',
                    align: pw.TextAlign.right),
                _tableCell('${item.subtotal.round()} kr',
                    align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildPackingTable(Order order) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _tableCell('OK', isHeader: true, align: pw.TextAlign.center),
            _tableCell('Produkt', isHeader: true),
            _tableCell('Antal', isHeader: true, align: pw.TextAlign.center),
          ],
        ),
        // Item rows with checkbox space
        ...order.items.map((item) => pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Container(
                    width: 15,
                    height: 15,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey600),
                    ),
                  ),
                ),
                _tableCell(item.productName),
                _tableCell(
                  '${item.quantity} st',
                  align: pw.TextAlign.center,
                  bold: true,
                ),
              ],
            )),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: isHeader || bold ? pw.FontWeight.bold : null,
          fontSize: isHeader ? 10 : 11,
        ),
      ),
    );
  }

  static pw.Widget _buildTotals(Order order) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          children: [
            _totalRow('Delsumma', order.subtotal),
            if (order.shipping > 0) _totalRow('Frakt', order.shipping),
            if (order.tax > 0) _totalRow('Moms', order.tax),
            pw.Divider(color: PdfColors.grey400),
            _totalRow('TOTALT', order.total, isBold: true, fontSize: 14),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, double amount,
      {bool isBold = false, double fontSize = 11}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              fontSize: fontSize,
            ),
          ),
          pw.Text(
            '${amount.round()} kr',
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _footerColumn('Perfect8 AB', 'Org.nr: 559XXX-XXXX'),
            _footerColumn('Adress', 'Exempelgatan 1\n123 45 Stockholm'),
            _footerColumn('Kontakt', 'info@perfect8.se\n+46 8 123 456'),
            _footerColumn('Bankgiro', '123-4567'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _footerColumn(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  static pw.Widget _buildCheckbox(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(
            width: 15,
            height: 15,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(label),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
