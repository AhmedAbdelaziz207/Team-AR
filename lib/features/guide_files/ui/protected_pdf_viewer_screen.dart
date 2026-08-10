import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';

// Protected PDF viewer screen using native SfPdfViewer with local caching
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
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    _downloadAndCachePdf();
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  Future<void> _downloadAndCachePdf() async {
    try {
      final driveRegex = RegExp(r'https://drive\.google\.com/file/d/([^/]+)');
      final match = driveRegex.firstMatch(widget.url);
      
      if (match == null) {
        throw Exception("رابط غير صالح");
      }
      
      final fileId = match.group(1)!;
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/$fileId.pdf';
      final file = File(localPath);
      
      // If already downloaded, show it instantly
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _localFilePath = localPath;
            _isLoading = false;
          });
        }
        return;
      }

      final initialUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      
      final dio = Dio(BaseOptions(
        followRedirects: false, // We handle HTML or redirects manually
        validateStatus: (status) => status != null && status < 500,
      ));
      
      final response = await dio.get(initialUrl, options: Options(responseType: ResponseType.bytes));
      
      String downloadUrl = initialUrl;
      List<int>? fileBytes;
      
      if (response.headers.value('content-type')?.contains('text/html') == true) {
        // Virus scan warning page
        final body = String.fromCharCodes(response.data as List<int>);
        
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
          
          downloadUrl = Uri.parse(actionUrl).replace(queryParameters: queryParams).toString();
          
          // Make second request to download the actual PDF
          final res2 = await dio.get(downloadUrl, options: Options(responseType: ResponseType.bytes));
          fileBytes = res2.data as List<int>;
        }
      } else if (response.statusCode == 302 || response.statusCode == 303) {
        // Direct redirect
        downloadUrl = response.headers.value('location') ?? initialUrl;
        final res2 = await dio.get(downloadUrl, options: Options(responseType: ResponseType.bytes));
        fileBytes = res2.data as List<int>;
      } else {
        fileBytes = response.data as List<int>;
      }

      if (fileBytes != null && fileBytes.isNotEmpty) {
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          setState(() {
            _localFilePath = localPath;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("لم يتم استلام بيانات الملف");
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
                    'جاري تجهيز الكتيب للمرة الأولى...',
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
              : SfPdfViewer.file(
                  File(_localFilePath!),
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

