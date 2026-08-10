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
  String _debugLog = "";

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

  void _addLog(String msg) {
    debugPrint("[PDF_DEBUG] $msg");
    if (mounted) {
      setState(() {
        _debugLog += "$msg\n";
      });
    }
  }

  Future<void> _downloadAndCachePdf() async {
    try {
      _addLog("1. Start fetching PDF for: ${widget.title}");
      _addLog("URL: ${widget.url}");
      
      final driveRegex = RegExp(r'https://drive\.google\.com/file/d/([^/]+)');
      final match = driveRegex.firstMatch(widget.url);
      
      if (match == null) {
        _addLog("Error: Invalid URL format, could not extract file ID.");
        throw Exception("رابط غير صالح");
      }
      
      final fileId = match.group(1)!;
      _addLog("2. Extracted File ID: $fileId");
      
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/$fileId.pdf';
      final file = File(localPath);
      
      // If already downloaded, show it instantly
      if (await file.exists()) {
        final length = await file.length();
        _addLog("3. File found in cache! Size: $length bytes");
        if (length > 100) {
           if (mounted) {
             setState(() {
               _localFilePath = localPath;
               _isLoading = false;
             });
           }
           return;
        } else {
           _addLog("Cache file is too small, redownloading...");
           await file.delete();
        }
      }

      final initialUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      _addLog("3. Requesting initial URL: $initialUrl");
      
      final dio = Dio(BaseOptions(
        followRedirects: false, // We handle HTML or redirects manually
        validateStatus: (status) => status != null && status < 500,
      ));
      
      final response = await dio.get(initialUrl, options: Options(responseType: ResponseType.bytes));
      _addLog("4. Initial response status: ${response.statusCode}");
      _addLog("Content-Type: ${response.headers.value('content-type')}");
      
      String downloadUrl = initialUrl;
      List<int>? fileBytes;
      
      if (response.headers.value('content-type')?.contains('text/html') == true) {
        _addLog("5. Got HTML! Might be virus scan warning. Parsing...");
        final body = String.fromCharCodes(response.data as List<int>);
        
        final actionMatch = RegExp(r'<form[^>]*action="([^"]+)"').firstMatch(body);
        final inputMatches = RegExp(r'<input[^>]*type="hidden"[^>]*name="([^"]+)"[^>]*value="([^"]*)"').allMatches(body);
        
        if (actionMatch != null) {
          String actionUrl = actionMatch.group(1)!;
          if (actionUrl.startsWith('/')) {
            actionUrl = "https://drive.google.com$actionUrl";
          }
          _addLog("Form Action URL: $actionUrl");
          
          final queryParams = <String, String>{};
          for (final m in inputMatches) {
            queryParams[m.group(1)!] = m.group(2)!;
          }
          
          downloadUrl = Uri.parse(actionUrl).replace(queryParameters: queryParams).toString();
          _addLog("6. Constructed Final Download URL. Length: ${downloadUrl.length}");
          
          // Make second request to download the actual PDF
          _addLog("7. Requesting Final Download URL...");
          final res2 = await dio.get(downloadUrl, options: Options(responseType: ResponseType.bytes));
          _addLog("Response 2 status: ${res2.statusCode}");
          _addLog("Response 2 Content-Type: ${res2.headers.value('content-type')}");
          fileBytes = res2.data as List<int>;
        } else {
          _addLog("Error: Could not find form in HTML.");
          throw Exception("لم نتمكن من تجاوز صفحة الحماية");
        }
      } else if (response.statusCode == 302 || response.statusCode == 303) {
        downloadUrl = response.headers.value('location') ?? initialUrl;
        _addLog("5. Got Redirect. Following to: ${downloadUrl.substring(0, downloadUrl.length > 50 ? 50 : downloadUrl.length)}...");
        final res2 = await dio.get(downloadUrl, options: Options(responseType: ResponseType.bytes));
        _addLog("Response 2 status: ${res2.statusCode}");
        _addLog("Response 2 Content-Type: ${res2.headers.value('content-type')}");
        fileBytes = res2.data as List<int>;
      } else {
        _addLog("5. Got direct file response.");
        fileBytes = response.data as List<int>;
      }

      if (fileBytes != null && fileBytes.isNotEmpty) {
        _addLog("8. Download complete! Total bytes: ${fileBytes.length}");
        if (fileBytes.length > 5) {
           final magic = String.fromCharCodes(fileBytes.sublist(0, 5));
           _addLog("Magic bytes: $magic");
           if (magic != "%PDF-") {
              _addLog("WARNING: File does not start with %PDF- !");
           }
        }
        await file.writeAsBytes(fileBytes);
        _addLog("9. Saved to local cache.");
        if (mounted) {
          setState(() {
            _localFilePath = localPath;
            _isLoading = false;
          });
        }
      } else {
        _addLog("Error: File bytes is empty or null.");
        throw Exception("لم يتم استلام بيانات الملف");
      }
    } catch (e) {
      _addLog("EXCEPTION CAUGHT: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء تحميل الكتيب:\n$e";
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
          ? Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF102E50)),
                      const SizedBox(height: 16),
                      const Text(
                        'جاري تجهيز الكتيب للمرة الأولى...',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _debugLog,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                fontFamily: 'Cairo', color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          const Text("سجل التتبع (Debug Log):", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black12,
                            child: Text(
                              _debugLog,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      ),
                    ),
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
                        _debugLog += "\n[SfPdfViewer Error]: ${details.error}\n${details.description}";
                      });
                    }
                  },
                ),
    );
  }
}

