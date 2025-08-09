// category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Category {
  allMenu,
  grills,
  salads,
  drinks,
  desserts,
  appitizes,
  sandwiches,
  pizza,
  fish,
  kidsMenu
}

// List of available categories
final categoriesProvider = Provider<List<String>>((ref) {
  return [
    Category.allMenu.name,
    Category.appitizes.name,
    Category.salads.name,
    Category.sandwiches.name,
    Category.pizza.name,
    Category.fish.name,
    Category.grills.name,
    Category.drinks.name,
    Category.desserts.name,
    Category.kidsMenu.name,
  ];
});

// Selected category ('all menu' at first)
final selectedCategoryProvider = StateProvider<String?>((ref) => 'all menu');
