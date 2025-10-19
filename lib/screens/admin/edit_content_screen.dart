import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/radio_content.dart';
import '../../providers/content_provider.dart';

class EditContentScreen extends StatefulWidget {
  final RadioContent content;

  const EditContentScreen({super.key, required this.content});

  @override
  State<EditContentScreen> createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoUrlController;
  late TextEditingController _audioUrlController;
  late TextEditingController _thumbnailUrlController;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.content.title);
    _descriptionController = TextEditingController(text: widget.content.description ?? '');
    _videoUrlController = TextEditingController(text: widget.content.videoUrl ?? '');
    _audioUrlController = TextEditingController(text: widget.content.audioUrl ?? '');
    _thumbnailUrlController = TextEditingController(text: widget.content.thumbnailUrl ?? '');
    _isActive = widget.content.isActive;
  }

  Future<void> _updateContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final content = widget.content.copyWith(
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
    );

    if (widget.content.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de contenido inválido'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final success = await context.read<ContentProvider>().updateContent(
          widget.content.id!,
          content,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenido actualizado exitosamente'),
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
        title: const Text('Editar Contenido'),
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
              onPressed: _isLoading ? null : _updateContent,
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
                      'Actualizar Contenido',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}