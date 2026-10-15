import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:team_ar/core/theme/app_colors.dart';

/// نوع منصة الفيديو المكتشفة تلقائياً
enum VideoPlatformType {
  youtube,
  youtubeShorts,
  facebook,
  instagram,
  directVideo,
  web,
}

/// مساعد ذكي لتحليل وفحص روابط الفيديوهات
class VideoUrlHelper {
  static VideoPlatformType detectPlatform(String url) {
    final lower = url.trim().toLowerCase();
    if (lower.contains('youtube.com/shorts/') || lower.contains('/shorts/')) {
      return VideoPlatformType.youtubeShorts;
    }
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return VideoPlatformType.youtube;
    }
    if (lower.contains('facebook.com') ||
        lower.contains('fb.watch') ||
        lower.contains('fb.com')) {
      return VideoPlatformType.facebook;
    }
    if (lower.contains('instagram.com')) {
      return VideoPlatformType.instagram;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('.mp4?')) {
      return VideoPlatformType.directVideo;
    }
    return VideoPlatformType.web;
  }

  /// هل الفيديو غالباً رأسي/طولي (Shorts / Reels)؟
  static bool isLikelyVertical(String url) {
    final lower = url.trim().toLowerCase();
    return lower.contains('/shorts/') ||
        lower.contains('/reel/') ||
        lower.contains('/reels/') ||
        lower.contains('fb.watch');
  }

  /// استخراج معرّف فيديو يوتيوب بدقة
  static String? extractYoutubeId(String url) {
    final clean = url.trim();
    // 1. محاولة YoutubePlayer الرسمية
    final id = YoutubePlayer.convertUrlToId(clean);
    if (id != null && id.isNotEmpty) return id;

    // 2. فحص نمط الشورتس youtube.com/shorts/{id}
    final shortsMatch =
        RegExp(r'shorts\/([a-zA-Z0-9_-]{8,15})').firstMatch(clean);
    if (shortsMatch != null && shortsMatch.groupCount >= 1) {
      return shortsMatch.group(1);
    }

    // 3. فحص الروابط العامة v={id}
    final vMatch =
        RegExp(r'(?:v=|\/)([a-zA-Z0-9_-]{11})(?:\?|&|$)').firstMatch(clean);
    if (vMatch != null && vMatch.groupCount >= 1) {
      return vMatch.group(1);
    }

    return null;
  }

  /// تنظيف وتجهيز روابط الفيديو وإزالة وسوم التتبع من فيسبوك
  static String cleanVideoUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return url;
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      if (host.contains('facebook.com') ||
          host.contains('fb.watch') ||
          host.contains('fb.com')) {
        // 1. استخراج معرّف الريل الصريح
        final reelMatch =
            RegExp(r'(?:reel|reels)\/(\d+)').firstMatch(uri.path);
        if (reelMatch != null && reelMatch.groupCount >= 1) {
          return 'https://www.facebook.com/reel/${reelMatch.group(1)}/';
        }

        // 2. نمط watch?v=ID
        if (uri.path.contains('watch') && uri.queryParameters.containsKey('v')) {
          final v = uri.queryParameters['v'];
          if (v != null && v.isNotEmpty) {
            return 'https://www.facebook.com/watch/?v=$v';
          }
        }

        // 3. تنظيف معاملات التتبع
        final cleanParams = Map<String, String>.from(uri.queryParameters)
          ..removeWhere((key, _) =>
              key.toLowerCase().startsWith('mibextid') ||
              key.toLowerCase().startsWith('__cft__') ||
              key.toLowerCase().startsWith('__tn__') ||
              key == 'fs' ||
              key == 's' ||
              key == 'fbclid' ||
              key == 'ref' ||
              key == 'rdid' ||
              key == 'locale');

        final cleanUri = uri.replace(
          host: 'www.facebook.com',
          queryParameters: cleanParams.isEmpty ? null : cleanParams,
          fragment: null,
        );
        return cleanUri.toString();
      }
    } catch (_) {}
    return url;
  }

  /// هل الرابط من روابط المشاركة المختصرة على فيسبوك التي تعتمد على التحويل 302؟
  static bool isFacebookShareUrl(String url) {
    final lower = url.trim().toLowerCase();
    return lower.contains('/share/r/') ||
        lower.contains('/share/v/') ||
        lower.contains('fb.watch');
  }

  /// تجهيز كود HTML لتضمين فيديو فيسبوك / ريلز عبر مشغل فيسبوك الرسمي
  static String generateFacebookEmbedHtml(String videoUrl) {
    final cleanUrl = cleanVideoUrl(videoUrl);
    final encoded = Uri.encodeComponent(cleanUrl);
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <iframe
    src="https://www.facebook.com/plugins/video.php?href=$encoded&show_text=false&width=500&autoplay=1"
    scrolling="no"
    frameborder="0"
    allowfullscreen="true"
    allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share">
  </iframe>
</body>
</html>
''';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// UNIVERSAL INLINE EXERCISE VIDEO PLAYER (المشغل الذكي الموحد في مكانه)
/// ═══════════════════════════════════════════════════════════════════════════════
class UniversalInlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String exerciseName;
  final int? exerciseIndex;
  final bool isLightMode;
  final bool isCurrentlyActive;
  final VoidCallback? onPlayStarted;

  const UniversalInlineVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.exerciseName,
    this.exerciseIndex,
    this.isLightMode = true,
    this.isCurrentlyActive = true,
    this.onPlayStarted,
  });

  @override
  State<UniversalInlineVideoPlayer> createState() =>
      _UniversalInlineVideoPlayerState();
}

class _UniversalInlineVideoPlayerState extends State<UniversalInlineVideoPlayer> {
  bool _isPlaying = false;
  late bool _isVertical;
  bool _isLoading = false;

  YoutubePlayerController? _ytController;
  WebViewController? _webViewController;

  late VideoPlatformType _platform;
  String? _youtubeId;

  @override
  void initState() {
    super.initState();
    _platform = VideoUrlHelper.detectPlatform(widget.videoUrl);
    _isVertical = VideoUrlHelper.isLikelyVertical(widget.videoUrl);
    if (_platform == VideoPlatformType.youtube ||
        _platform == VideoPlatformType.youtubeShorts) {
      _youtubeId = VideoUrlHelper.extractYoutubeId(widget.videoUrl);
    }
  }

  @override
  void didUpdateWidget(covariant UniversalInlineVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغير الرابط
    if (oldWidget.videoUrl != widget.videoUrl) {
      _stopPlayback();
      _platform = VideoUrlHelper.detectPlatform(widget.videoUrl);
      _isVertical = VideoUrlHelper.isLikelyVertical(widget.videoUrl);
      if (_platform == VideoPlatformType.youtube ||
          _platform == VideoPlatformType.youtubeShorts) {
        _youtubeId = VideoUrlHelper.extractYoutubeId(widget.videoUrl);
      }
    }
    // إذا تم تفعيل تمرين آخر، أوقف الفيديو الحالي تلقائياً
    if (!widget.isCurrentlyActive && _isPlaying) {
      _stopPlayback();
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  void _startPlayback() {
    HapticFeedback.mediumImpact();
    widget.onPlayStarted?.call();

    setState(() {
      _isPlaying = true;
      _isLoading = true;
    });

    if (_youtubeId != null && _youtubeId!.isNotEmpty) {
      // مشغل يوتيوب المدمج
      _ytController = YoutubePlayerController(
        initialVideoId: _youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: false,
          loop: true,
          enableCaption: false,
        ),
      );
      setState(() => _isLoading = false);
    } else {
      // مشغل الويب المدمج لفيسبوك والروابط الأخرى
      _initWebPlayer();
    }
  }

  Future<void> _openExternal(BuildContext context) async {
    HapticFeedback.lightImpact();
    final clean = VideoUrlHelper.cleanVideoUrl(widget.videoUrl);
    try {
      final uri = Uri.parse(clean);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح الرابط الخارجي: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }

  void _initWebPlayer() {
    try {
      final web = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            onWebResourceError: (err) {
              log('WebPlayer Error: ${err.description}');
              setState(() => _isLoading = false);
            },
            onNavigationRequest: (req) {
              final uri = Uri.tryParse(req.url);
              final host = uri?.host.toLowerCase() ?? '';
              if (host.contains('facebook.com') ||
                  host.contains('fbcdn.net') ||
                  host.contains('fbsbx.com') ||
                  host.contains('instagram.com') ||
                  host.contains('cdninstagram.com') ||
                  host.contains('youtube.com') ||
                  host.contains('googlevideo.com') ||
                  req.url.startsWith('data:') ||
                  req.url.startsWith('about:')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        );

      if (_platform == VideoPlatformType.facebook) {
        final clean = VideoUrlHelper.cleanVideoUrl(widget.videoUrl);
        if (VideoUrlHelper.isFacebookShareUrl(clean)) {
          // روابط المشاركة المختصرة /share/r/ أو fb.watch تُحمّل مباشرة لتتبع تحويل 302
          web.loadRequest(Uri.parse(clean));
        } else {
          // روابط الفيديوهات المباشرة تُضمّن بمشغل فيسبوك الرسمي
          final html = VideoUrlHelper.generateFacebookEmbedHtml(clean);
          web.loadHtmlString(html, baseUrl: 'https://www.facebook.com');
        }
      } else {
        web.loadRequest(Uri.parse(widget.videoUrl.trim()));
      }

      setState(() {
        _webViewController = web;
      });
    } catch (e) {
      log('Error initializing web player: $e');
      setState(() => _isLoading = false);
    }
  }

  void _stopPlayback() {
    _ytController?.pause();
    _ytController?.dispose();
    _ytController = null;
    _webViewController = null;
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
    }
  }

  void _toggleAspectRatio() {
    HapticFeedback.selectionClick();
    setState(() {
      _isVertical = !_isVertical;
    });
  }

  void _openFullscreen(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoViewer(
          videoUrl: widget.videoUrl,
          exerciseName: widget.exerciseName,
          platform: _platform,
          youtubeId: _youtubeId,
          isVertical: _isVertical,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return _buildThumbnailPreview();
    }
    return _buildActiveInlinePlayer();
  }

  // ─── 1. بطاقة الغلاف الأنيقة قبل التشغيل ─────────────────────────────────
  Widget _buildThumbnailPreview() {
    final isYt = _youtubeId != null && _youtubeId!.isNotEmpty;
    final isFb = _platform == VideoPlatformType.facebook;

    String platformBadge = 'شرح التمرين 🎬';
    Color platformColor = const Color(0xFFEF4444);
    IconData platformIcon = Icons.play_circle_fill_rounded;

    if (isYt) {
      platformBadge = _platform == VideoPlatformType.youtubeShorts
          ? 'YouTube Shorts ⚡'
          : 'YouTube 🎬';
      platformColor = const Color(0xFFEF4444);
      platformIcon = Icons.ondemand_video_rounded;
    } else if (isFb) {
      platformBadge = 'Facebook Reel 🔵';
      platformColor = const Color(0xFF1877F2);
      platformIcon = Icons.play_arrow_rounded;
    } else if (_platform == VideoPlatformType.instagram) {
      platformBadge = 'Instagram Reel 🟣';
      platformColor = const Color(0xFFE1306C);
      platformIcon = Icons.camera_alt_rounded;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _startPlayback,
            child: Stack(
              children: [
                // خلفية الصورة (يوتيوب أو تدرج أنيق)
                SizedBox(
                  width: double.infinity,
                  height: 135.h,
                  child: isYt
                      ? Image.network(
                          'https://img.youtube.com/vi/$_youtubeId/hqdefault.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackGradient(),
                        )
                      : _buildFallbackGradient(),
                ),

                // طبقة التعتيم والتدرج السينمائي
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // الشارات العلوية: المنصة + التنسيق
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  right: 10.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // شارة المنصة
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 3.5.h),
                        decoration: BoxDecoration(
                          color: platformColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(platformIcon,
                                size: 12.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              platformBadge,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // شارة التنسيق (طولي / عرضي)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.5.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isVertical
                                  ? Icons.stay_current_portrait_rounded
                                  : Icons.stay_current_landscape_rounded,
                              size: 11.sp,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _isVertical ? 'طولي 9:16' : 'عرضي 16:9',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9.5.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // زر التشغيل المركزي الكبير المتوهج
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: platformColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: platformColor.withValues(alpha: 0.5),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),

                // الشريط السفلي: عنوان التمرين وتنبيه "تشغيل الفيديو في مكانه"
                Positioned(
                  bottom: 8.h,
                  left: 12.w,
                  right: 12.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تشغيل تكنيك ${widget.exerciseName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'تشغيل في مكانه 🎬',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ─── 2. المشغل الحي المدمج في مكانه (Inline Active Player) ──────────────
  Widget _buildActiveInlinePlayer() {
    // تحديد الارتفاع بحسب النمط (طولي للريلز والشورتس vs عرضي)
    final double playerHeight = _isVertical ? 360.h : 210.h;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط أدوات المشغل العلوي
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  // نقطة البث الحي
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      widget.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // زر التبديل بين الطولي والعرضي (16:9 / 9:16)
                  Tooltip(
                    message: _isVertical ? 'تحويل لعرضي 16:9' : 'تحويل لطولي 9:16',
                    child: InkWell(
                      onTap: _toggleAspectRatio,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isVertical
                                  ? Icons.stay_current_portrait_rounded
                                  : Icons.stay_current_landscape_rounded,
                              size: 13.sp,
                              color: const Color(0xFF38BDF8),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _isVertical ? 'طولي' : 'عرضي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9.5.sp,
                                color: const Color(0xFF38BDF8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),

                  // زر فتح الرابط بالتطبيق المخصص
                  IconButton(
                    tooltip: 'فتح في ${_platform == VideoPlatformType.facebook ? 'تطبيق فيسبوك' : 'المتصفح'}',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.open_in_new_rounded,
                        color: Colors.white, size: 18.sp),
                    onPressed: () => _openExternal(context),
                  ),
                  SizedBox(width: 6.w),

                  // زر ملء الشاشة
                  IconButton(
                    tooltip: 'تكبير ملء الشاشة',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.fullscreen_rounded,
                        color: Colors.white, size: 20.sp),
                    onPressed: () => _openFullscreen(context),
                  ),
                  SizedBox(width: 6.w),

                  // زر إيقاف المشغل والعودة للغلاف
                  IconButton(
                    tooltip: 'إيقاف الفيديو',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close_rounded,
                        color: Colors.white70, size: 20.sp),
                    onPressed: _stopPlayback,
                  ),
                ],
              ),
            ),

            // مساحة الفيديو الفعلية
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: playerHeight,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_youtubeId != null && _ytController != null)
                    YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppColors.newPrimaryColor,
                      progressColors: const ProgressBarColors(
                        playedColor: AppColors.newPrimaryColor,
                        handleColor: AppColors.newPrimaryColor,
                      ),
                      onReady: () => setState(() => _isLoading = false),
                    )
                  else if (_webViewController != null)
                    WebViewWidget(controller: _webViewController!)
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.newPrimaryColor,
                      ),
                    ),

                  if (_isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.newPrimaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // شريط إرشادي ذكي لفيسبوك في حال تعذر التضمين بسبب قيود الخصوصية
            if (_platform == VideoPlatformType.facebook)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                color: const Color(0xFF0F172A),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: const Color(0xFF38BDF8), size: 14.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'الفيديو لا يفتح؟ (قد تكون الخصوصية محددة من الناشر)',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9.5.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _openExternal(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'فتح بفيسبوك',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.open_in_new_rounded,
                                color: Colors.white, size: 11.sp),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// FULLSCREEN VIDEO VIEWER (شاشة العرض المكبرة بملء الشاشة مع الرجوع السلس)
/// ═══════════════════════════════════════════════════════════════════════════════
class _FullscreenVideoViewer extends StatefulWidget {
  final String videoUrl;
  final String exerciseName;
  final VideoPlatformType platform;
  final String? youtubeId;
  final bool isVertical;

  const _FullscreenVideoViewer({
    required this.videoUrl,
    required this.exerciseName,
    required this.platform,
    this.youtubeId,
    required this.isVertical,
  });

  @override
  State<_FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<_FullscreenVideoViewer> {
  YoutubePlayerController? _ytCtrl;
  WebViewController? _webCtrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.youtubeId != null && widget.youtubeId!.isNotEmpty) {
      _ytCtrl = YoutubePlayerController(
        initialVideoId: widget.youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: false,
          loop: true,
        ),
      );
      _isLoading = false;
    } else {
      _initWebPlayer();
    }
  }

  Future<void> _openExternal(BuildContext context) async {
    HapticFeedback.lightImpact();
    final clean = VideoUrlHelper.cleanVideoUrl(widget.videoUrl);
    try {
      final uri = Uri.parse(clean);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح الرابط الخارجي: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }

  void _initWebPlayer() {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (req) {
            final uri = Uri.tryParse(req.url);
            final host = uri?.host.toLowerCase() ?? '';
            if (host.contains('facebook.com') ||
                host.contains('fbcdn.net') ||
                host.contains('fbsbx.com') ||
                host.contains('instagram.com') ||
                host.contains('cdninstagram.com') ||
                host.contains('youtube.com') ||
                host.contains('googlevideo.com') ||
                req.url.startsWith('data:') ||
                req.url.startsWith('about:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    if (widget.platform == VideoPlatformType.facebook) {
      final clean = VideoUrlHelper.cleanVideoUrl(widget.videoUrl);
      if (VideoUrlHelper.isFacebookShareUrl(clean)) {
        _webCtrl!.loadRequest(Uri.parse(clean));
      } else {
        final html = VideoUrlHelper.generateFacebookEmbedHtml(clean);
        _webCtrl!.loadHtmlString(html, baseUrl: 'https://www.facebook.com');
      }
    } else {
      _webCtrl!.loadRequest(Uri.parse(widget.videoUrl.trim()));
    }
  }

  @override
  void dispose() {
    _ytCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'فتح في التطبيق الخارجي / فيسبوك',
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
            onPressed: () => _openExternal(context),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.youtubeId != null && _ytCtrl != null)
                Center(
                  child: YoutubePlayer(
                    controller: _ytCtrl!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.newPrimaryColor,
                  ),
                )
              else if (_webCtrl != null)
                WebViewWidget(controller: _webCtrl!)
              else
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.newPrimaryColor,
                  ),
                ),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.newPrimaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
