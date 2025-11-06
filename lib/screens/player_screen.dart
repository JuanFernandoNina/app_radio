import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/radio_content.dart';

class PlayerScreen extends StatefulWidget {
  final RadioContent content;

  const PlayerScreen({super.key, required this.content});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isVideoMode = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get hasAudio =>
      widget.content.audioUrl != null && widget.content.audioUrl!.isNotEmpty;
  bool get hasVideo =>
      widget.content.videoUrl != null && widget.content.videoUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    try {
      if (hasVideo) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.content.videoUrl!),
        );
        await _videoController!.initialize();
        _videoController!.addListener(() {
          if (_videoController!.value.isInitialized) {
            setState(() {
              _position = _videoController!.value.position;
              _duration = _videoController!.value.duration;
              _isPlaying = _videoController!.value.isPlaying;
            });
          }
        });
      }

      if (hasAudio) {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setUrl(widget.content.audioUrl!);
        _audioPlayer!.durationStream.listen((d) {
          if (d != null) setState(() => _duration = d);
        });
        _audioPlayer!.positionStream.listen((p) {
          setState(() => _position = p);
        });
        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error inicializando: $e');
    }
  }

  void _togglePlayPause() async {
    if (_isVideoMode && _videoController != null) {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
    } else if (_audioPlayer != null) {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play();
      }
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _selectAudio() async {
    setState(() {
      _isVideoMode = false;
      _isPlaying = false;
    });
    await _videoController?.pause();
    await _audioPlayer?.pause();
  }

  void _selectVideo() async {
    setState(() {
      _isVideoMode = true;
      _isPlaying = false;
    });
    await _audioPlayer?.pause();
    await _videoController?.pause();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = hasAudio || hasVideo;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.content.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagen o video
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.brown[300],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isVideoMode &&
                                _videoController != null &&
                                _videoController!.value.isInitialized)
                              AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: widget.content.thumbnailUrl ?? '',
                                fit: BoxFit.cover,
                                height: 250,
                                width: double.infinity,
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Text(
                                    "imagen/video",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Título y descripción
                    Text(
                      widget.content.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.content.description ?? '',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // ======= CONTROLES ABAJO =======
            if (hasMedia)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botones audio/video
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasAudio)
                          _modeButton(
                            label: "audio",
                            isSelected: !_isVideoMode,
                            onTap: _selectAudio,
                          ),
                        if (hasAudio && hasVideo) const SizedBox(width: 12),
                        if (hasVideo)
                          _modeButton(
                            label: "video",
                            isSelected: _isVideoMode,
                            onTap: _selectVideo,
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Barra progreso
                    if (_duration.inSeconds > 0)
                      Column(
                        children: [
                          Slider(
                            value: _position.inSeconds.toDouble(),
                            max: _duration.inSeconds.toDouble(),
                            activeColor: Colors.yellow[700],
                            inactiveColor: Colors.grey[300],
                            onChanged: (value) async {
                              final newPos = Duration(seconds: value.toInt());
                              if (_isVideoMode && _videoController != null) {
                                await _videoController!.seekTo(newPos);
                              } else {
                                await _audioPlayer?.seek(newPos);
                              }
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_position),
                                    style: const TextStyle(color: Colors.grey)),
                                Text(_formatDuration(_duration),
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),

                    // Botón play/pause
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 70,
                        color: Colors.yellow[700],
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

  Widget _modeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.yellow[700]! : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
