import 'package:flutter/material.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// Protected PDF viewer screen using native SfPdfViewer
// No download, no share, no external access
class ProtectedPdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const ProtectedPdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ProtectedPdfViewerScreen> createState() =>
      _ProtectedPdfViewerScreenState();
}

class _ProtectedPdfViewerScreenState extends State<ProtectedPdfViewerScreen> {
  late String _pdfUrl;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    _initUrl();
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  void _initUrl() {
    // Convert Google Drive share link to direct download link for native rendering
    _pdfUrl = widget.url;
    final driveRegex = RegExp(
      r'https://drive\.google\.com/file/d/([^/]+)',
    );
    final match = driveRegex.firstMatch(widget.url);
    if (match != null) {
      final fileId = match.group(1);
      // Use Google Drive direct download (uc?export=download)
      _pdfUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
        // No actions - no download, no share, no menu
        actions: const [],
      ),
      body: SfPdfViewer.network(
        _pdfUrl,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
