import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/carousel_item.dart';
import '../../providers/carousel_provider.dart';

class EditCarouselScreen extends StatefulWidget {
  final CarouselItem item;

  const EditCarouselScreen({super.key, required this.item});

  @override
  State<EditCarouselScreen> createState() => _EditCarouselScreenState();
}

class _EditCarouselScreenState extends State<EditCarouselScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _linkUrlController;
  late TextEditingController _orderController;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description ?? '');
    _imageUrlController = TextEditingController(text: widget.item.imageUrl);
    _linkUrlController = TextEditingController(text: widget.item.linkUrl ?? '');
    _orderController = TextEditingController(text: widget.item.orderPosition.toString());
    _isActive = widget.item.isActive;
  }

  Future<void> _updateCarousel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final item = widget.item.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      linkUrl: _linkUrlController.text.trim().isEmpty
          ? null
          : _linkUrlController.text.trim(),
      isActive: _isActive,
      orderPosition: int.tryParse(_orderController.text) ?? 0,
    );

    final success = await context.read<CarouselProvider>().updateCarousel(
          widget.item.id,
          item,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banner actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${context.read<CarouselProvider>().error}'),
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
    _imageUrlController.dispose();
    _linkUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Banner'),
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
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Imagen *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://ejemplo.com/imagen.jpg',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La URL de imagen es requerida';
                }
                if (!value.startsWith('http')) {
                  return 'Debe ser una URL válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Enlace (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: 'https://ejemplo.com',
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
              controller: _orderController,
              decoration: const InputDecoration(
                labelText: 'Orden de Posición',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sort),
                hintText: '0, 1, 2...',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Banner Activo'),
              subtitle: const Text('Visible en el carrusel'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateCarousel,
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
                      'Actualizar Banner',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}