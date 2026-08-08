import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  /// Genera el PDF del ticket con formato angosto tipo rollo térmico (80mm).
  static Future<Uint8List> buildTicketPdf({
    required String businessName,
    required String location,
    required String phone,
    required String tipo,
    required String expression,
    required String resultText,
    required String fechaHora,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                businessName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              if (location.isNotEmpty)
                pw.Text(location, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
              if (phone.isNotEmpty)
                pw.Text(phone, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Text(tipo, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(expression, style: const pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
              pw.Text('------', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 4),
              pw.Text(resultText, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(fechaHora, style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
