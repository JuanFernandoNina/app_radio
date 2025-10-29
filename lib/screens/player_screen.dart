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
  bool _isPlayingAudio = false;
  bool _isPlayingVideo = false;
  bool _showVideo = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    try {
      // Inicializar video si existe
      if (widget.content.videoUrl != null &&
          widget.content.videoUrl!.isNotEmpty) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.content.videoUrl!),
        );
        await _videoController!.initialize();
        setState(() {});
      }

      // Inicializar audio si existe
      if (widget.content.audioUrl != null &&
          widget.content.audioUrl!.isNotEmpty) {
        _audioPlayer = AudioPlayer();

        // Intentar cargar el audio
        try {
          final uri = Uri.parse(widget.content.audioUrl!);

          // Si es http/https, validamos antes
          if (uri.scheme == 'http' || uri.scheme == 'https') {
            // Verificar si el archivo existe
            final response =
                await Uri.parse(widget.content.audioUrl!).resolveUri(uri);
            debugPrint('Cargando audio desde: $response');
          }

          await _audioPlayer!.setUrl(widget.content.audioUrl!);
        } on PlayerException catch (e) {
          debugPrint('⚠️ Error al reproducir el audio: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'No se pudo cargar el audio. Verifica la URL o la conexión.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return; // salir si no se pudo cargar
        } catch (e) {
          debugPrint('❌ Error inesperado: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al inicializar el reproductor de audio.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Escuchar cambios de duración
        _audioPlayer!.durationStream.listen((duration) {
          if (duration != null) {
            setState(() => _audioDuration = duration);
          }
        });

        // Escuchar cambios de posición
        _audioPlayer!.positionStream.listen((position) {
          setState(() => _audioPosition = position);
        });

        // Escuchar cuando termina
        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlayingAudio = false;
              _audioPosition = Duration.zero;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error al inicializar reproductores: $e');
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
      await _audioPlayer!.play();
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
      await _videoController!.play();
    }
    setState(() {
      _isPlayingVideo = !_isPlayingVideo;
      _showVideo = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen o Video
                  if (_showVideo &&
                      _videoController != null &&
                      _videoController!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  else if (widget.content.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.content.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber[700]!, Colors.amber[900]!],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.radio, size: 100, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[400]!, Colors.amber[700]!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.radio, size: 100, color: Colors.white),
                      ),
                    ),

                  // Gradiente oscuro
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.content.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Controles de Reproducción
                  if (widget.content.audioUrl != null ||
                      widget.content.videoUrl != null)
                    _buildPlayerControls(),

                  const SizedBox(height: 32),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 24),

                  // Descripción
                  if (widget.content.description != null &&
                      widget.content.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description_outlined,
                                color: Colors.amber[700], size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.content.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                  // Información adicional
                  _buildMediaInfo(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[50]!,
            Colors.amber[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de progreso (solo para audio)
          if (widget.content.audioUrl != null && _isPlayingAudio)
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.amber[700],
                    inactiveTrackColor: Colors.amber[200],
                    thumbColor: Colors.amber[700],
                    overlayColor: Colors.amber.withOpacity(0.2),
                    trackHeight: 6,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _audioPosition.inSeconds.toDouble(),
                    max: _audioDuration.inSeconds.toDouble() > 0
                        ? _audioDuration.inSeconds.toDouble()
                        : 1.0,
                    onChanged: (value) {
                      _audioPlayer?.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_audioPosition),
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDuration(_audioDuration),
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Audio
              if (widget.content.audioUrl != null)
                Expanded(
                  child: _buildControlButton(
                    icon: _isPlayingAudio
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    label: _isPlayingAudio ? 'Pausar' : 'Audio',
                    color: Colors.amber[700]!,
                    onTap: _toggleAudio,
                  ),
                ),

              if (widget.content.audioUrl != null &&
                  widget.content.videoUrl != null)
                const SizedBox(width: 16),

              // Botón Video
              if (widget.content.videoUrl != null)
                Expanded(
                  child: _buildControlButton(
                    icon: _isPlayingVideo
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    label: _isPlayingVideo ? 'Pausar' : 'Video',
                    color: Colors.amber[600]!,
                    onTap: _toggleVideo,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 22),
              const SizedBox(width: 8),
              const Text(
                'Información del contenido',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.audiotrack,
            'Audio',
            widget.content.audioUrl != null ? 'Disponible' : 'No disponible',
            widget.content.audioUrl != null,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.videocam,
            'Video',
            widget.content.videoUrl != null ? 'Disponible' : 'No disponible',
            widget.content.videoUrl != null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, bool available) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: available ? Colors.amber[700] : Colors.grey[400],
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: available ? Colors.amber[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: available ? Colors.white : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
