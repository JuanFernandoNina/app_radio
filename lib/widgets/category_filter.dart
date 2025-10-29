import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.blue;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String? iconString) {
    switch (iconString) {
      case 'music_note':
        return Icons.music_note;
      case 'newspaper':
        return Icons.newspaper;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'mic':
        return Icons.mic;
      case 'podcasts':
        return Icons.podcasts;
      case 'live_tv':
        return Icons.live_tv;
      case 'star':
        return Icons.star;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Chip "Todos"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todos'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onCategorySelected(null),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.amber,
              labelStyle: TextStyle(
                color: selectedCategoryId == null ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              checkmarkColor: Colors.white,
            ),
          ),

          // Chips de categorías
          ...categories.map((category) {
            final color = _parseColor(category.color);
            final isSelected = selectedCategoryId == category.id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _parseIcon(category.icon),
                      size: 18,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 4),
                    Text(category.name),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(category.id),
                backgroundColor: color.withOpacity(0.2),
                selectedColor: color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
