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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'CHACALTAYA',
              style: TextStyle(
                color: Color(0xFFFFB700),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'MÚSICA',
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 25,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: Consumer2<ContentProvider, CategoryProvider>(
        builder: (context, contentProvider, categoryProvider, child) {
          if (contentProvider.isLoading || categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB700)),
              ),
            );
          }

          if (contentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: const Color(0xFFFFB700)),
                  const SizedBox(height: 16),
                  Text(
                    'Sin conexión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica tu conexión a Internet\ne intenta nuevamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      contentProvider.loadActiveContent();
                      categoryProvider.loadCategories();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB700),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        fontFamily: 'Inter',
                      ),
                    ),
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
            color: const Color(0xFFFFB700),
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
                          'Explora nuestra música',
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${gruposCategories.length} categorías disponibles',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista horizontal de categorías
                if (gruposCategories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gruposCategories.length,
                        itemBuilder: (context, index) {
                          final category = gruposCategories[index];
                          final isSelected = _selectedCategoryId == category.id;

                          // Contar contenido por categoría
                          final contentCount = contentProvider.contents
                              .where((c) => c.categoryId == category.id)
                              .length;

                          return Padding(
                            padding: EdgeInsets.only(
                              right:
                                  index < gruposCategories.length - 1 ? 12 : 0,
                            ),
                            child: SizedBox(
                              width: 160,
                              child: _buildCategoryCard(
                                category: category,
                                contentCount: contentCount,
                                isSelected: isSelected,
                                onTap: () {
                                  _filterByCategory(
                                      isSelected ? null : category.id);
                                },
                              ),
                            ),
                          );
                        },
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
                        icon: Icon(Icons.grid_view,
                            color: const Color(0xFFFFB700)),
                        label: const Text(
                          'Ver todas las categorías',
                          style: TextStyle(
                            color: Color(0xFFFFB700),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
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
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
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
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFFB700),
                            ),
                            child: const Text(
                              'Ver todo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFFFB700) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFFFFB700).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: isSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 143, 143, 143),
                      size: 28,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$contentCount contenidos',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'Inter',
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
