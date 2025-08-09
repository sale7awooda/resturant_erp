// providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/menu/categories/categories_provider.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';

// Menu items list (mock)
final menuProvider = Provider<List<MenuItemModel>>((ref) {
  return [
    MenuItemModel(
        id: '1',
        name: 'Burger',
        categ: Category.sandwiches.name, // Example category
        price: 5.0,
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '2',
        name: 'Pizza',
        categ: Category.pizza.name, // Example category
        price: 8.0,
        options: ['Cheese', 'Pepperoni', 'Veggie']),
    MenuItemModel(
        id: '3',
        name: 'Coffee',
        categ: Category.drinks.name,
        price: 3.0,
        options: ['Hot', 'Iced']),
    MenuItemModel(
        id: '4',
        name: 'Burger',
        categ: Category.sandwiches.name, // Example category
        price: 5.0,
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '5',
        name: 'Pizza',
        categ: Category.pizza.name, // Example category
        price: 8.0,
        options: ['Cheese', 'Pepperoni', 'Veggie']),
    MenuItemModel(
        id: '6',
        name: 'Coffee',
        categ: Category.drinks.name,
        price: 3.0,
        options: ['Hot', 'Iced']),
  ];
});

// selected option per item (in-memory UI state).
// Map<itemId, selectedOption>
final selectedOptionsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

// Filtered items provider (example: just return all, or you can map categories to filters)
final filteredMenuProvider = Provider<List<MenuItemModel>>((ref) {
  final all = ref.watch(menuProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'all menu') return all;
  // Example filter (for demo purposes, filtering by name contains)
  return all
      .where((m) => m.name.toLowerCase().contains(category!.toLowerCase()))
      .toList();
});
