import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/category_provider.dart';
import '../providers/carousel_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/carousel_banner.dart';
import '../widgets/category_filter.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Mostrar la pantalla enseguida y cargar en segundo plano
      Future.microtask(() {
        context.read<ContentProvider>().loadActiveContent();
        context.read<CategoryProvider>().loadCategories();
        context.read<CarouselProvider>().loadActiveCarousel();
      });
    });
  }

  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  static const Color _kAccent = Colors.amber;

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
                color: _kAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'MIEMBROS',
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
      body: Consumer3<ContentProvider, CategoryProvider, CarouselProvider>(
        builder: (context, contentProvider, categoryProvider, carouselProvider,
            child) {
          if (contentProvider.isLoading || categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
              ),
            );
          }

          if (contentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: _kAccent),
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
                      carouselProvider.loadActiveCarousel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
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
                  )
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
              await carouselProvider.loadActiveCarousel();
            },
            child: CustomScrollView(
              slivers: [
                // Carrusel
                if (carouselProvider.items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 15),
                      child: CarouselBanner(items: carouselProvider.items),
                    ),
                  ),

                // Texto descriptivo de categorías
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explora por categorías',
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Filtra el contenido por tu categoría favorita',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            fontFamily: 'Inter',
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
                        categories: categoryProvider.categories
                            .where((cat) =>
                                cat.screen == 'home' || cat.screen == 'both')
                            .toList(),
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: _filterByCategory,
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
                            Icons.radio,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin contenido disponible',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ContentCard(content: filteredContents[index]);
                        },
                        childCount: filteredContents.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
