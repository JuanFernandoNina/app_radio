import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/category_filter.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Cargar datos cuando se monta la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadActiveContent();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Grupos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda próximamente')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<ContentProvider, CategoryProvider>(
        builder: (context, contentProvider, categoryProvider, child) {
          if (contentProvider.isLoading || categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (contentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${contentProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      contentProvider.loadActiveContent();
                      categoryProvider.loadCategories();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Filtrar contenido por categoría
          final filteredContents = _selectedCategoryId == null
              ? contentProvider.contents
              : contentProvider.contents
                  .where((c) => c.categoryId == _selectedCategoryId)
                  .toList();

          return RefreshIndicator(
            onRefresh: () async {
              await contentProvider.loadActiveContent();
              await categoryProvider.loadCategories();
            },
            color: Colors.deepPurple,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              slivers: [
                // Header con descripción
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explora por Grupos',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 70, 70, 70),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Encuentra contenido organizado por categorías',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filtro de categorías
                if (categoryProvider.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CategoryFilter(
                        categories: categoryProvider.categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: _filterByCategory,
                      ),
                    ),
                  ),

                // Contador de resultados
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      _selectedCategoryId == null
                          ? 'Mostrando todos (${filteredContents.length})'
                          : 'Encontrados: ${filteredContents.length}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Lista de contenido
                if (filteredContents.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategoryId == null
                                ? 'No hay contenido disponible'
                                : 'No hay contenido en esta categoría',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                            child: const Text('Ver todo'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ContentCard(content: filteredContents[index]);
                        },
                        childCount: filteredContents.length,
                      ),
                    ),
                  ),

                // Espaciado inferior
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
