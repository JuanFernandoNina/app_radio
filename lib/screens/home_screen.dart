import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primaryColor = Color.fromARGB(255, 255, 166, 0);

  // ✅ Tu stream original
  static const _streamUrl = "https://stream.zeno.fm/rihjsl5lkhmuv";

  // ✅ Stream de respaldo (funciona mejor en emuladores)
  static const _backupStreamUrl = "https://icecast.radiofrance.fr/fip-hifi.aac";

  static const _radioLogo = "https://i.postimg.cc/xTmMhR4m/img-radio.png";

  late final AudioPlayer _player;
  double _volume = 0.5;
  bool _isInitializing = true;
  String _statusMessage = 'Cargando radio...';
  bool _usingBackupStream = false;

  final List<Map<String, String>> _socialMedia = [
    {"icon": "assets/Icon/facebook.png", "url": "https://facebook.com"},
    {
      "icon": "assets/Icon/whassapp.png",
      "url": "https://wa.me/yourphonenumber"
    },
    {"icon": "assets/Icon/instagram.png", "url": "https://instagram.com"},
    {"icon": "assets/Icon/facebook.png", "url": "https://tusitioweb.com"},
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // ✅ Inicializar DESPUÉS de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAudioPlayer();
    });
  }

  Future<void> _initAudioPlayer() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _statusMessage = 'Conectando a Radio Chacaltaya...';
    });

    String urlToTry = _streamUrl;

    // ✅ Intentar con el stream principal primero
    bool success = await _tryLoadStream(urlToTry);

    // ✅ Si falla, intentar con stream de respaldo (solo para pruebas en emulador)
    if (!success) {
      debugPrint("⚠️ Stream principal falló, intentando respaldo...");
      setState(() {
        _statusMessage = 'Probando conexión alternativa...';
        _usingBackupStream = true;
      });

      urlToTry = _backupStreamUrl;
      success = await _tryLoadStream(urlToTry);
    }

    if (mounted) {
      if (success) {
        await _player.setVolume(_volume);
        debugPrint("🔊 Volumen configurado: $_volume");

        setState(() {
          _statusMessage =
              _usingBackupStream ? '¡Modo prueba activado!' : '¡Radio lista!';
        });

        if (_usingBackupStream) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Usando stream de prueba. Prueba en dispositivo físico para mejor experiencia.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = 'Error de conexión';
        });

        _showErrorDialog();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isInitializing = false);
    }
  }

  Future<bool> _tryLoadStream(String url) async {
    try {
      debugPrint("🎵 Intentando cargar: $url");

      await _player
          .setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '1',
            album: "Radio Chacaltaya",
            title: "En vivo",
            artUri: Uri.parse(_radioLogo),
          ),
        ),
      )
          .timeout(
        const Duration(seconds: 15), // ✅ Reducido a 15 seg para fallar rápido
        onTimeout: () {
          throw Exception('Timeout al conectar');
        },
      );

      debugPrint("✅ Stream cargado exitosamente: $url");
      return true;
    } catch (e) {
      debugPrint("❌ Error con $url: $e");
      return false;
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.red),
            SizedBox(width: 12),
            Text('Error de Conexión'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No se pudo conectar a la radio. Posibles causas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Estás usando un emulador (usa dispositivo físico)'),
            Text('• Conexión a internet lenta o inestable'),
            Text('• El servidor de radio está caído'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initAudioPlayer();
            },
            child: const Text('REINTENTAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Stack(
          children: [
            _buildMainContent(),
            if (_isInitializing) _buildLoadingOverlay(),
            _buildPlayerControls(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Center(
        child: Image.asset('images/Logo.png', fit: BoxFit.contain, height: 80),
      ),
      backgroundColor: Colors.transparent,
      toolbarHeight: 120,
      elevation: 0,
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color.fromARGB(200, 255, 166, 0),
          Color.fromARGB(200, 233, 140, 0),
          Color.fromARGB(117, 255, 208, 0),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Esto puede tardar unos segundos...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          _buildRadioImageCard(),
          const SizedBox(height: 10),
          _buildRadioInfo(),
          const SizedBox(height: 2),
          _buildSocialMediaButtons(),
        ],
      ),
    );
  }

  Widget _buildRadioImageCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Image.asset(
          'assets/img/radio.png',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRadioInfo() {
    return Column(
      children: [
        const Text(
          'Radio Chacaltaya 97.16',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black54,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const Text.rich(
          TextSpan(
            text: 'CONDUCE: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'JUAN NINA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Open Sans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _socialMedia
          .map(
            (social) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _SocialMediaButton(
                icon: social["icon"]!,
                onPressed: () => _launchUrl(social["url"]!),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlayerControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 0,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVolumeControl(),
            const SizedBox(height: 15),
            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        const Icon(Icons.volume_down, size: 30, color: Colors.black54),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            activeColor: _primaryColor,
            inactiveColor: Colors.grey[300],
            onChanged: (value) {
              setState(() => _volume = value);
              _player.setVolume(value);
            },
          ),
        ),
        const Icon(Icons.volume_up, size: 30, color: Colors.black54),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;
        final processingState =
            snapshot.data?.processingState ?? ProcessingState.idle;
        final isLoading = processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous,
                  size: 35, color: Colors.black54),
              onPressed: () {},
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.deepPurple,
                elevation: 8,
              ),
              onPressed: (_isInitializing || isLoading)
                  ? null
                  : () {
                      if (isPlaying) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                    },
              child: SizedBox(
                width: 35,
                height: 35,
                child: (isLoading || _isInitializing)
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 35,
                        color: Colors.white,
                      ),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon:
                  const Icon(Icons.skip_next, size: 35, color: Colors.black54),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}

class _SocialMediaButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _SocialMediaButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Image.asset(icon, width: 45, height: 45),
      ),
    );
  }
}
