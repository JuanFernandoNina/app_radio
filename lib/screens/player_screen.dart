import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
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
  bool _isPlayingAudio = false;
  bool _isPlayingVideo = false;
  bool _showVideo = false;
  StreamSubscription<PlayerState>? _audioStateSub;
  StreamSubscription<PlaybackEvent>? _audioEventSub;
  // NOTE: variable removed — errors are shown to user via SnackBar

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    // Inicializar video si existe
    if (widget.content.videoUrl != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.content.videoUrl!),
        );
        await _videoController!.initialize();
        setState(() {});
      } catch (e) {
        // Video initialization failed (network / format / CORS)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar video: ${e.toString()}')),
          );
        }
      }
    }

    // Inicializar audio si existe
    if (widget.content.audioUrl != null) {
      _audioPlayer = AudioPlayer();

      // escuchas para detectar errores en reproducción
      _audioStateSub = _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.idle && state.playing) {
          // estado raro, posible desconexión
        }
      });
      _audioEventSub = _audioPlayer!.playbackEventStream.listen((event) {
        // si hay errors desde el source, se pueden ver aquí
        if (event.processingState == ProcessingState.idle && event.updatePosition == Duration.zero) {
          // noop
        }
      }, onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en reproducción de audio: ${err.toString()}')),
          );
        }
      });

      // Intentos de conexión con reintento simple
      const maxAttempts = 3;
      var attempt = 0;
      var connected = false;
      while (attempt < maxAttempts && !connected) {
        attempt++;
        try {
          // usar AudioSource.uri para permitir añadir headers si fueran necesarios
          final source = AudioSource.uri(Uri.parse(widget.content.audioUrl!));
          await _audioPlayer!.setAudioSource(source);
          connected = true;
        } catch (e) {
          // Si es una interrupción de conexión, reintentamos con backoff
          if (attempt >= maxAttempts) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No se pudo conectar al audio (intentos: $attempt): ${e.toString()}')),
              );
            }
          } else {
            await Future.delayed(Duration(seconds: 2 * attempt));
          }
        }
      }
    }
  }

  void _toggleAudio() async {
    if (_audioPlayer == null) return;

    if (_isPlayingAudio) {
      await _audioPlayer!.pause();
    } else {
      if (_isPlayingVideo) {
        await _videoController?.pause();
        setState(() => _isPlayingVideo = false);
      }
      try {
        await _audioPlayer!.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al reproducir audio: ${e.toString()}')),
          );
        }
        return;
      }
    }
    setState(() => _isPlayingAudio = !_isPlayingAudio);
  }

  void _toggleVideo() async {
    if (_videoController == null) return;

    if (_isPlayingVideo) {
      await _videoController!.pause();
    } else {
      if (_isPlayingAudio) {
        await _audioPlayer?.pause();
        setState(() => _isPlayingAudio = false);
      }
      try {
        await _videoController!.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al reproducir video: ${e.toString()}')),
          );
        }
        return;
      }
    }
    setState(() {
      _isPlayingVideo = !_isPlayingVideo;
      _showVideo = true;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioStateSub?.cancel();
    _audioEventSub?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player
            if (_showVideo && _videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            else if (widget.content.thumbnailUrl != null)
              Image.network(
                widget.content.thumbnailUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.radio, size: 80),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.content.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Controles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Audio control
                      if (widget.content.audioUrl != null)
                        ElevatedButton.icon(
                          onPressed: _toggleAudio,
                          icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow),
                          label: Text(_isPlayingAudio ? 'Pausar Audio' : 'Reproducir Audio'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      
                      if (widget.content.audioUrl != null && widget.content.videoUrl != null)
                        const SizedBox(width: 16),
                      
                      // Video control
                      if (widget.content.videoUrl != null)
                        ElevatedButton.icon(
                          onPressed: _toggleVideo,
                          icon: Icon(_isPlayingVideo ? Icons.pause : Icons.play_arrow),
                          label: Text(_isPlayingVideo ? 'Pausar Video' : 'Reproducir Video'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  if (widget.content.description != null) ...[
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.content.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}