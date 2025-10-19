import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/category_provider.dart';
import '../providers/carousel_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/carousel_banner.dart';
import '../widgets/category_filter.dart';
import 'admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadActiveContent();
      context.read<CategoryProvider>().loadCategories();
      context.read<CarouselProvider>().loadActiveCarousel();
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
      appBar: AppBar(
        title: const Text('Radio App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer3<ContentProvider, CategoryProvider, CarouselProvider>(
        builder: (context, contentProvider, categoryProvider, carouselProvider, child) {
          if (contentProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      carouselProvider.loadActiveCarousel();
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
              : contentProvider.contents.where((c) => c.categoryId == _selectedCategoryId).toList();

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
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: CarouselBanner(items: carouselProvider.items),
                    ),
                  ),

                // Filtro de categorías
                if (categoryProvider.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CategoryFilter(
                        categories: categoryProvider.categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: _filterByCategory,
                      ),
                    ),
                  ),

                // Lista de contenido
                if (filteredContents.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radio, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay contenido disponible',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
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