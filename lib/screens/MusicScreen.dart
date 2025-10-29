import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/content_card.dart';
import '../models/category.dart';

class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadActiveContent();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  // Filtrar categorías que pertenecen a "grupos" o "both"
  List<Category> _getGruposCategories(List<Category> allCategories) {
    return allCategories
        .where((cat) => cat.screen == 'grupos' || cat.screen == 'both')
        .toList();
  }

  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

          // Obtener solo las categorías de grupos
          final gruposCategories =
              _getGruposCategories(categoryProvider.categories);

          // Obtener IDs de las categorías de grupos
          final gruposCategoryIds = gruposCategories.map((c) => c.id).toList();

          // Filtrar contenido: solo mostrar contenido de categorías de grupos
          List filteredContents;

          if (_selectedCategoryId != null) {
            // Si hay una categoría seleccionada, filtrar por ella
            filteredContents = contentProvider.contents
                .where((c) => c.categoryId == _selectedCategoryId)
                .toList();
          } else {
            // Si no hay categoría seleccionada, mostrar TODO el contenido de grupos
            filteredContents = contentProvider.contents
                .where((c) =>
                    c.categoryId != null &&
                    gruposCategoryIds.contains(c.categoryId))
                .toList();
          }

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
                        const Text(
                          'Explora por Grupos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contenido organizado en ${gruposCategories.length} categorías',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid de categorías (tipo Spotify)
                if (gruposCategories.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = gruposCategories[index];
                          final isSelected = _selectedCategoryId == category.id;

                          // Contar contenido por categoría
                          final contentCount = contentProvider.contents
                              .where((c) => c.categoryId == category.id)
                              .length;

                          return _buildCategoryCard(
                            category: category,
                            contentCount: contentCount,
                            isSelected: isSelected,
                            onTap: () {
                              _filterByCategory(
                                  isSelected ? null : category.id);
                            },
                          );
                        },
                        childCount: gruposCategories.length,
                      ),
                    ),
                  ),

                // Botón "Ver todos"
                if (_selectedCategoryId != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                        icon: const Icon(Icons.grid_view,
                            color: Colors.deepPurple),
                        label: const Text(
                          'Ver todas las categorías',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ),

                // Título de contenido
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          _selectedCategoryId == null
                              ? 'Todo el contenido'
                              : 'Contenido de ${gruposCategories.firstWhere((c) => c.id == _selectedCategoryId).name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${filteredContents.length})',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                            'No hay contenido en esta categoría',
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

  Widget _buildCategoryCard({
    required Category category,
    required int contentCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Parsear color
    Color categoryColor;
    try {
      categoryColor = category.color != null
          ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
          : Colors.deepPurple;
    } catch (e) {
      categoryColor = Colors.deepPurple;
    }

    // Parsear icono
    IconData categoryIcon;
    switch (category.icon) {
      case 'music_note':
        categoryIcon = Icons.music_note;
        break;
      case 'newspaper':
        categoryIcon = Icons.newspaper;
        break;
      case 'sports_soccer':
        categoryIcon = Icons.sports_soccer;
        break;
      case 'mic':
        categoryIcon = Icons.mic;
        break;
      case 'podcasts':
        categoryIcon = Icons.podcasts;
        break;
      case 'live_tv':
        categoryIcon = Icons.live_tv;
        break;
      case 'star':
        categoryIcon = Icons.star;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [categoryColor, categoryColor.withOpacity(0.7)]
                  : [
                      categoryColor.withOpacity(0.3),
                      categoryColor.withOpacity(0.1)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected ? Border.all(color: categoryColor, width: 2) : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    categoryIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$contentCount contenidos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
