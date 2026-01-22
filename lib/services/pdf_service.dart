import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  /// 📁 Pick a PDF file from the device
  static Future<File?> pickPDF() async {
    try {
      print('📁 Opening file picker...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        print('✅ PDF selected: ${result.files.single.name}');
        return file;
      }

      print('⚠️ No file selected');
      return null;

    } catch (e) {
      print('❌ Error picking PDF: $e');
      return null;
    }
  }

  /// 📖 Extract text from a PDF file
  static Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      print('📖 Loading PDF...');

      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final int pageCount = document.pages.count;
      print('📄 PDF has $pageCount pages');

      final PdfTextExtractor extractor = PdfTextExtractor(document);

      final StringBuffer extracted = StringBuffer();

      for (int i = 0; i < pageCount; i++) {
        final String pageText = extractor.extractText(startPageIndex: i);
        extracted.writeln(pageText);
        extracted.writeln();

        print('✅ Extracted page ${i + 1}/$pageCount');
      }

      document.dispose();

      String fullText = extracted.toString().trim();
      print('📚 Extracted total: ${fullText.length} characters');

      /// Limit text length for AI (important)
      const int limit = 15000;
      if (fullText.length > limit) {
        print('⚠️ Text too long, truncating to $limit characters');
        fullText = fullText.substring(0, limit);
      }

      return fullText;

    } catch (e) {
      print('❌ Error extracting PDF text: $e');
      throw Exception('Failed to extract text: $e');
    }
  }
}
