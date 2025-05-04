import 'package:flutter/material.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutVideoScreen extends StatefulWidget {
  const WorkoutVideoScreen({super.key});

  @override
  State<WorkoutVideoScreen> createState() => _WorkoutVideoScreenState();
}

class _WorkoutVideoScreenState extends State<WorkoutVideoScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isMuted = false;

  final String videoUrl = 'https://youtu.be/_aHyBEPIXSs?si=1JH2Ox28Pfo_aXKx';

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      )..addListener(_listener);
    } else {
      debugPrint("Invalid YouTube URL");
    }
  }

  void _listener() {
    // if (_isPlayerReady && mounted) {
    //   setState(() {
    //    _controller.play();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videoUrl.isEmpty
          ? const Center(child: Text("No video URL provided"))
          : YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          liveUIColor: AppColors.newPrimaryColor,
          progressColors: const ProgressBarColors(
            playedColor:  AppColors.newPrimaryColor
          ),

          showVideoProgressIndicator: true,
          onReady: () {
            setState(() {
              _isPlayerReady = true;
              _controller.play();
            });
          },
          onEnded: (_) => _controller.seekTo(Duration.zero),
        ),
        builder: (context, player) => Column(
          children: [
            Expanded(child: player),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                  ),
                  onPressed: _isPlayerReady
                      ? () {
                    setState(() {
                      _isMuted
                          ? _controller.unMute()
                          : _controller.mute();
                      _isMuted = !_isMuted;
                    });
                  }
                      : null,
                ),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: _isPlayerReady
                      ? () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
