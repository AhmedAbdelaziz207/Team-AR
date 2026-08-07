import 'package:flutter/material.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Protected PDF viewer screen using internal WebView
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
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    _initWebView();
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  void _initWebView() {
    // Convert Google Drive share link to direct embed link
    String viewUrl = widget.url;
    final driveRegex = RegExp(
      r'https://drive\.google\.com/file/d/([^/]+)',
    );
    final match = driveRegex.firstMatch(widget.url);
    if (match != null) {
      final fileId = match.group(1);
      // Use Google Drive preview (no download button, no share)
      viewUrl = 'https://drive.google.com/file/d/$fileId/preview';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          // Block any navigation to external links or downloads
          onNavigationRequest: (request) {
            final url = request.url;
            // Allow only Google Drive preview URLs
            if (url.contains('drive.google.com') &&
                url.contains('preview')) {
              return NavigationDecision.navigate;
            }
            // Block everything else (download links, external sites)
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(viewUrl));
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF102E50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل الكتيب...',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
