import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFFEC4899);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  
  static const gradients = [
    [Color(0xFF6366F1), Color(0xFFA855F7)],
    [Color(0xFFEC4899), Color(0xFFF43F5E)],
    [Color(0xFF10B981), Color(0xFF3B82F6)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
  ];
}

class CategoryMeta {
  final String name;
  final IconData icon;
  final List<Color> gradient;

  CategoryMeta(this.name, this.icon, this.gradient);
}

final List<CategoryMeta> appCategories = [
  CategoryMeta('All', Icons.grid_view_rounded, [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
  CategoryMeta('Work', Icons.work_outline_rounded, [Color(0xFF3B82F6), Color(0xFF2DD4BF)]),
  CategoryMeta('Personal', Icons.person_outline_rounded, [Color(0xFFEC4899), Color(0xFFD946EF)]),
  CategoryMeta('Study', Icons.menu_book_rounded, [Color(0xFFF59E0B), Color(0xFFF97316)]),
  CategoryMeta('Fitness', Icons.fitness_center_rounded, [Color(0xFF10B981), Color(0xFF059669)]),
  CategoryMeta('Finance', Icons.payments_outlined, [Color(0xFF6366F1), Color(0xFF4F46E5)]),
  CategoryMeta('Health', Icons.favorite_border_rounded, [Color(0xFFEF4444), Color(0xFFDC2626)]),
  CategoryMeta('Shopping', Icons.shopping_bag_outlined, [Color(0xFF8B5CF6), Color(0xFFC084FC)]),
];
