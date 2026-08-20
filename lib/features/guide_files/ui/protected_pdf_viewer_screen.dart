import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// Protected PDF viewer screen using native SfPdfViewer with local caching
// No download, no share, no external access, with robust Google Drive large file handling
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
  String _statusMessage = 'جاري تجهيز الكتيب...';
  double? _downloadProgress;
  int _receivedBytes = 0;
  int? _totalBytes;
  HttpClient? _activeClient;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    _loadOrDownloadPdf();
  }

  @override
  void dispose() {
    _activeClient?.close(force: true);
    PdfProtectionService.disable();
    super.dispose();
  }

  void _addLog(String msg) {
    debugPrint("[PDF_DEBUG] $msg");
  }

  String? _extractFileId(String url) {
    final match = RegExp(r'(?:file/d/|id=)([a-zA-Z0-9_-]+)').firstMatch(url);
    return match?.group(1);
  }

  Future<bool> _isValidPdf(File file) async {
    if (!await file.exists()) return false;
    final length = await file.length();
    if (length < 1024) return false;

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      final headerBytes = await raf.read(5);
      final header = String.fromCharCodes(headerBytes);
      return header == '%PDF-';
    } catch (e) {
      _addLog("Validation error: $e");
      return false;
    } finally {
      await raf?.close();
    }
  }

  Future<void> _loadOrDownloadPdf() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = null;
      _receivedBytes = 0;
      _totalBytes = null;
      _statusMessage = 'جاري فحص الكتيب...';
    });

    try {
      final fileId = _extractFileId(widget.url);
      if (fileId == null) {
        throw Exception("رابط غير صالح: لم يتم العثور على معرّف الكتيب");
      }

      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/$fileId.pdf';
      final file = File(localPath);

      // Step 1: Check existing cache and verify its integrity
      if (await file.exists()) {
        final isValid = await _isValidPdf(file);
        if (isValid) {
          _addLog("Valid cache found for $fileId (${await file.length()} bytes)");
          if (mounted) {
            setState(() {
              _localFilePath = localPath;
              _isLoading = false;
            });
          }
          return;
        } else {
          _addLog("Corrupted or invalid cache file found. Deleting...");
          try {
            await file.delete();
          } catch (_) {}
        }
      }

      // Step 2: Download file using stream with Google Drive virus scan bypass
      await _downloadGoogleDrivePdf(fileId: fileId, targetFile: file);

      if (mounted) {
        setState(() {
          _localFilePath = localPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      _addLog("Download/Load error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ أثناء تحميل الكتيب:\n$e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadGoogleDrivePdf({
    required String fileId,
    required File targetFile,
  }) async {
    final tempFile = File('${targetFile.path}.tmp');
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {}
    }

    final client = HttpClient();
    _activeClient = client;
    client.connectionTimeout = const Duration(seconds: 30);
    client.autoUncompress = true;

    try {
      var currentUri = Uri.parse(
          'https://drive.google.com/uc?export=download&id=$fileId&confirm=t');
      final cookies = <Cookie>[];
      IOSink? tempSink;

      _updateStatus("جاري الاتصال بالسيرفر...");

      for (int step = 0; step < 8; step++) {
        final req = await client.getUrl(currentUri);
        req.followRedirects = false;
        req.headers.set('User-Agent',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        for (final c in cookies) {
          req.cookies.add(c);
        }

        final res = await req.close();
        cookies.addAll(res.cookies);

        // Handle redirects (301, 302, 303, 307, 308)
        if (res.statusCode == 301 ||
            res.statusCode == 302 ||
            res.statusCode == 303 ||
            res.statusCode == 307 ||
            res.statusCode == 308) {
          final loc = res.headers.value('location');
          await res.drain(); // Crucial to release connection socket
          if (loc == null) {
            throw Exception("فشل إعادة التوجيه من السيرفر");
          }
          if (loc.startsWith('/')) {
            currentUri = Uri(
              scheme: currentUri.scheme,
              host: currentUri.host,
              port: currentUri.port,
              path: loc,
            );
          } else {
            currentUri = Uri.parse(loc);
          }
          continue;
        }

        final contentType = res.headers.contentType?.mimeType ?? '';
        final contentLength =
            res.headers.contentLength > 0 ? res.headers.contentLength : null;

        // If response is HTML (Google Drive virus scan warning for files > 100MB)
        if (contentType.contains('text/html')) {
          final bytes = <int>[];
          await for (final chunk in res) {
            bytes.addAll(chunk);
          }
          final html = utf8.decode(bytes, allowMalformed: true);

          if (html.contains('<form')) {
            _updateStatus("تجهيز الملفات الكبيرة...");
            final actionMatch =
                RegExp(r'<form[^>]*action="([^"]+)"', caseSensitive: false)
                    .firstMatch(html);
            final inputMatches = RegExp(
                    r'<input[^>]*type="hidden"[^>]*name="([^"]+)"[^>]*value="([^"]*)"',
                    caseSensitive: false)
                .allMatches(html);

            if (actionMatch != null) {
              var actionUrl = actionMatch.group(1)!;
              if (actionUrl.startsWith('/')) {
                actionUrl = 'https://${currentUri.host}$actionUrl';
              }
              final qp = <String, String>{};
              for (final m in inputMatches) {
                qp[m.group(1)!] = m.group(2)!;
              }
              if (!qp.containsKey('confirm')) qp['confirm'] = 't';
              if (!qp.containsKey('id')) qp['id'] = fileId;

              currentUri = Uri.parse(actionUrl).replace(queryParameters: qp);
              continue;
            }
          }
          throw Exception("استجابة غير متوقعة من السيرفر (صفحة ويب وليست كتيب)");
        }

        // Stream download directly to temporary file
        _updateStatus("جاري تنزيل الكتيب...");
        tempSink = tempFile.openWrite();
        int received = 0;

        if (mounted) {
          setState(() {
            _totalBytes = contentLength;
          });
        }

        await for (final chunk in res) {
          tempSink.add(chunk);
          received += chunk.length;
          if (mounted) {
            setState(() {
              _receivedBytes = received;
              if (contentLength != null && contentLength > 0) {
                _downloadProgress = received / contentLength;
              }
            });
          }
        }

        await tempSink.flush();
        await tempSink.close();
        tempSink = null;
        
        if (contentLength != null && contentLength > 0 && received < contentLength) {
          throw Exception("تم قطع الاتصال قبل اكتمال التحميل. الحجم: $received من $contentLength");
        }
        break;
      }

      // Check PDF validity
      final valid = await _isValidPdf(tempFile);
      if (!valid) {
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        throw Exception("الملف الذي تم تنزيله غير مكتمل أو تالف");
      }

      // Atomic rename to final target file
      if (await targetFile.exists()) {
        try {
          await targetFile.delete();
        } catch (_) {}
      }
      await tempFile.rename(targetFile.path);
    } catch (e) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      client.close();
      _activeClient = null;
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _statusMessage = status;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
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
      ),
      body: _isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF102E50).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: Color(0xFF102E50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF102E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_downloadProgress != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF102E50)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${_formatBytes(_receivedBytes)} / ${_totalBytes != null ? _formatBytes(_totalBytes!) : ''} (${((_downloadProgress ?? 0) * 100).toStringAsFixed(0)}%)",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (_receivedBytes > 0) ...[
                      const LinearProgressIndicator(
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF102E50)),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "تم تنزيل: ${_formatBytes(_receivedBytes)}",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF102E50),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text(
                      'يتم التجهيز مرة واحدة فقط ويُحفظ الكتيب للاستخدام لاحقاً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadOrDownloadPdf,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white),
                          label: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF102E50),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SfPdfViewer.file(
                  File(_localFilePath!),
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  onDocumentLoadFailed: (details) {
                    if (mounted) {
                      // If sf viewer failed to render, clear file and show error with retry
                      try {
                        File(_localFilePath!).deleteSync();
                      } catch (_) {}
                      setState(() {
                        _errorMessage = "فشل فتح الكتيب: ${details.error}";
                        _addLog(
                            "[SfPdfViewer Error]: ${details.error}\n${details.description}");
                      });
                    }
                  },
                ),
    );
  }
}
