import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/theme/app_theme.dart';
class PdfPreviewWidget extends StatefulWidget {
  final String pdfUrl;

  const PdfPreviewWidget({super.key, required this.pdfUrl});

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  String? _errorMessage;

  String get _fullPdfUrl => '${ApiEndPoints.baseUrl}/Exercises/${widget.pdfUrl}';

  void _onPdfLoaded() {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onPdfError(details) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load PDF. Please try again.';
      });
    }
  }

  Future<void> _retryLoading() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Preview'),
        centerTitle: true,
        elevation: 0,
        leading:     IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CupertinoColors.black,
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer
          if (_errorMessage == null)
            SfPdfViewer.network(
              _fullPdfUrl,
              key: _pdfViewerKey,
              onDocumentLoaded: (_) => _onPdfLoaded(),
              onDocumentLoadFailed: _onPdfError,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              canShowPaginationDialog: true,
            ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading workout plan...'),
                ],
              ),
            ),

          // Error Message
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops!',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _retryLoading,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
