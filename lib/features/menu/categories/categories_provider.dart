// category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Category {
  allMenu,
  grill,
  salad,
  drink,
  dessert,
  appitizer,
  sandwich,
  pizza,
  fish,
  kids
}

// List of available categories
final categoriesProvider = Provider<List<String>>((ref) {
  return [
    Category.allMenu.name,
    Category.appitizer.name,
    Category.sandwich.name,
    Category.pizza.name,
    Category.kids.name,
    Category.grill.name,
    Category.fish.name,
    Category.drink.name,
    Category.salad.name,
    Category.dessert.name,
  ];
});

// Selected category ('all menu' at first)
final selectedCategoryProvider =
    StateProvider<String?>((ref) => Category.allMenu.name);
