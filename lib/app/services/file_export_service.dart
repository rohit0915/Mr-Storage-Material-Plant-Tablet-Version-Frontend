import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class FileExportService {
  FileExportService._();

  static Uint8List csvBytes(List<List<dynamic>> rows) =>
      Uint8List.fromList(const ListToCsvConverter().convert(rows).codeUnits);

  static Future<String> saveCsv({
    required String fileName,
    required List<List<dynamic>> rows,
  }) => FileSaver.instance.saveFile(
    name: fileName,
    bytes: csvBytes(rows),
    fileExtension: 'csv',
    mimeType: MimeType.csv,
  );

  static Future<String> saveExcel({
    required String fileName,
    required List<List<dynamic>> rows,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Sheet1'];
    for (final row in rows) {
      sheet.appendRow(row.map((value) => TextCellValue('$value')).toList());
    }
    final encoded = workbook.encode();
    if (encoded == null) throw Exception('Unable to create Excel file.');
    return FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(encoded),
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  static Future<String> savePdf({
    required String fileName,
    required Uint8List bytes,
  }) => FileSaver.instance.saveFile(
    name: fileName,
    bytes: bytes,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );

  static Future<void> printPdf({
    required String name,
    required Uint8List bytes,
  }) => Printing.layoutPdf(name: name, onLayout: (_) async => bytes);

  static Future<void> sharePdf({
    required String fileName,
    required Uint8List bytes,
    String? text,
  }) => SharePlus.instance.share(
    ShareParams(
      text: text,
      files: [
        XFile.fromData(
          bytes,
          mimeType: 'application/pdf',
          name: '$fileName.pdf',
        ),
      ],
      fileNameOverrides: ['$fileName.pdf'],
      downloadFallbackEnabled: true,
    ),
  );

  static Future<Uint8List> tablePdf({
    required String title,
    String? subtitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(subtitle),
          ],
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey100,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );
    return document.save();
  }
}
