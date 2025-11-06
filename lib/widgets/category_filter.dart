import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  // Design constants
  static const Color _kAccent =
      Color(0xFFFFB700); // Amarillo brillante como en la imagen
  static const Color _kOnAccent = Colors.white;
  static const double _kHeight = 50.0;
  static const double _kIconSize = 16.0;
  static const double _kSpacing = 10.0;

  const CategoryFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  // Removed unused _parseColor method

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
      height: _kHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Chip "Todos"
          Padding(
            padding: EdgeInsets.only(right: _kSpacing),
            child: FilterChip(
              label: const Text(
                'Todos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              selected: selectedCategoryId == null,
              onSelected: (_) => onCategorySelected(null),
              backgroundColor:
                  selectedCategoryId == null ? _kAccent : Colors.grey[100],
              selectedColor: _kAccent,
              labelStyle: TextStyle(
                color:
                    selectedCategoryId == null ? _kOnAccent : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              checkmarkColor: _kOnAccent,
              elevation: 0,
              pressElevation: 0,
              side: BorderSide.none,
            ),
          ),

          // Chips de categorías
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category.id;

            return Padding(
              padding: EdgeInsets.only(right: _kSpacing),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _parseIcon(category.icon),
                      size: _kIconSize,
                      color: isSelected ? _kOnAccent : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(category.id),
                backgroundColor:
                    isSelected ? _kAccent : const Color(0xFFF5F5F5),
                selectedColor: _kAccent,
                labelStyle: TextStyle(
                  color: isSelected ? _kOnAccent : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                checkmarkColor: _kOnAccent,
                elevation: 0,
                pressElevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
