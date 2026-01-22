import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Service for handling PDF file operations
class PDFService {
  // Let user pick a PDF file from their device
  static Future<File?> pickPDF() async {
    try {
      print('📁 Opening file picker...');
      
      // Open file picker with PDF filter
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],  // Only allow PDF files
      );
      
      // Check if user selected a file
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        print('✅ PDF selected: ${result.files.single.name}');
        return file;
      } else {
        print('⚠️ No file selected');
        return null;
      }
      
    } catch (e) {
      print('❌ Error picking PDF: $e');
      return null;
    }
  }
  
  // Extract text content from PDF file
  static Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      print('📖 Reading PDF file...');
      
      // Read PDF file as bytes
      final bytes = await pdfFile.readAsBytes();
      
      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      print('📄 PDF has ${document.pages.count} pages');
      
      // Extract text from all pages
      String fullText = '';
      
      for (int i = 0; i < document.pages.count; i++) {
        // Create text extractor
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        
        // Extract text from current page
        final String pageText = extractor.extractText(startPageIndex: i);
        
        fullText += pageText + '\n\n';
        
        print('✅ Extracted page ${i + 1}/${document.pages.count}');
      }
      
      // Clean up
      document.dispose();
      
      print('✅ Total extracted: ${fullText.length} characters');
      
      // Limit text length (AI has token limits)
      // Gemini Pro can handle ~30,000 tokens, roughly 10,000 words
      if (fullText.length > 15000) {
        print('⚠️ Text too long, truncating to 15000 characters');
        fullText = fullText.substring(0, 15000);
      }
      
      return fullText.trim();
      
    } catch (e) {
      print('❌ Error extracting PDF text: $e');
      throw Exception('Failed to read PDF: $e');
    }
  }
}