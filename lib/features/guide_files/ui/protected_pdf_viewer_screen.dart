import 'package:flutter/material.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';

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
  String? _finalPdfUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    _resolveUrl();
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  Future<void> _resolveUrl() async {
    try {
      String viewUrl = widget.url;
      final driveRegex = RegExp(r'https://drive\.google\.com/file/d/([^/]+)');
      final match = driveRegex.firstMatch(widget.url);
      
      if (match != null) {
        final fileId = match.group(1);
        final initialUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
        
        final dio = Dio(BaseOptions(
          followRedirects: false, // We want to manually handle HTML or redirects
          validateStatus: (status) => status != null && status < 500,
        ));
        
        final response = await dio.get(initialUrl);
        
        if (response.headers.value('content-type')?.contains('text/html') == true) {
          // Virus scan warning page
          final body = response.data.toString();
          
          final actionMatch = RegExp(r'<form[^>]*action="([^"]+)"').firstMatch(body);
          final inputMatches = RegExp(r'<input[^>]*type="hidden"[^>]*name="([^"]+)"[^>]*value="([^"]*)"').allMatches(body);
          
          if (actionMatch != null) {
            String actionUrl = actionMatch.group(1)!;
            if (actionUrl.startsWith('/')) {
              actionUrl = "https://drive.google.com$actionUrl";
            }
            
            final queryParams = <String, String>{};
            for (final m in inputMatches) {
              queryParams[m.group(1)!] = m.group(2)!;
            }
            
            viewUrl = Uri.parse(actionUrl).replace(queryParameters: queryParams).toString();
          } else {
            viewUrl = initialUrl;
          }
        } else if (response.statusCode == 302 || response.statusCode == 303) {
          // Direct redirect
          viewUrl = response.headers.value('location') ?? initialUrl;
        } else {
          viewUrl = initialUrl;
        }
      }

      if (mounted) {
        setState(() {
          _finalPdfUrl = viewUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء تحميل الكتيب";
          _isLoading = false;
        });
      }
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
        actions: const [],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF102E50)),
                  SizedBox(height: 16),
                  Text(
                    'جاري تجهيز الكتيب...',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        fontFamily: 'Cairo', color: Colors.red, fontSize: 16),
                  ),
                )
              : SfPdfViewer.network(
                  _finalPdfUrl!,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  onDocumentLoadFailed: (details) {
                    if (mounted) {
                      setState(() {
                        _errorMessage = "فشل تحميل الكتيب: ${details.error}";
                      });
                    }
                  },
                ),
    );
  }
}
