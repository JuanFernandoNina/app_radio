import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/radio_content.dart';
import '../../providers/content_provider.dart';

class AddContentScreen extends StatefulWidget {
  const AddContentScreen({super.key});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final content = RadioContent(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      videoUrl: _videoUrlController.text.trim().isEmpty
          ? null
          : _videoUrlController.text.trim(),
      audioUrl: _audioUrlController.text.trim().isEmpty
          ? null
          : _audioUrlController.text.trim(),
      thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
          ? null
          : _thumbnailUrlController.text.trim(),
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await context.read<ContentProvider>().createContent(content);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenido creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${context.read<ContentProvider>().error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Contenido'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Miniatura',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://ejemplo.com/imagen.jpg',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.startsWith('http')) {
                    return 'Debe ser una URL válida';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _audioUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Audio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.audiotrack),
                hintText: 'https://ejemplo.com/audio.mp3',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.startsWith('http')) {
                    return 'Debe ser una URL válida';
                  }
                }
                // Validar que al menos haya audio o video
                if ((value == null || value.trim().isEmpty) &&
                    _videoUrlController.text.trim().isEmpty) {
                  return 'Debe proporcionar al menos un audio o video';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Video',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.videocam),
                hintText: 'https://ejemplo.com/video.mp4',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.startsWith('http')) {
                    return 'Debe ser una URL válida';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Contenido Activo'),
              subtitle: const Text('Visible para los usuarios'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveContent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Guardar Contenido',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• El título es obligatorio\n'
                      '• Debe proporcionar al menos un audio o video\n'
                      '• Las URLs deben comenzar con http:// o https://\n'
                      '• Puedes usar servicios como Supabase Storage para alojar archivos',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}