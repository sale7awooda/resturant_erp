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
        categ: Category.sandwich.name, // Example category
        price: 5.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '2',
        name: 'Pizza',
        categ: Category.pizza.name, // Example category
        price: 8.0,
        img: 'assets/images/img.png',
        options: ['Cheese', 'Pepperoni', 'Veggie']),
    MenuItemModel(
        id: '3',
        name: 'Coffee2',
        categ: Category.drink.name,
        price: 3.0,
        img: 'assets/images/img.png',
        options: ['Hot', 'Iced']),
    MenuItemModel(
        id: '4',
        name: 'Burger',
        categ: Category.sandwich.name, // Example category
        price: 5.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '5',
        name: 'Pizza',
        categ: Category.pizza.name, // Example category
        price: 8.0,
        img: 'assets/images/img.png',
        options: ['Cheese', 'Pepperoni', 'Veggie']),
    MenuItemModel(
        id: '6',
        name: 'Coffee',
        categ: Category.drink.name,
        price: 3.0,
        img: 'assets/images/img.png',
        options: ['Hot', 'Iced']),
    MenuItemModel(
        id: '7',
        name: 'orange juice',
        categ: Category.drink.name, // Example category
        price: 4.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '8',
        name: 'water',
        categ: Category.drink.name, // Example category
        price: 2.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '9',
        name: 'fruit salad',
        categ: Category.dessert.name,
        price: 13.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '10',
        name: 'brouwni cake',
        categ: Category.dessert.name, // Example category
        price: 5.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '11',
        name: 'fried chicken',
        categ: Category.grill.name, // Example category
        price: 18.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
    MenuItemModel(
        id: '12',
        name: 'fried fish',
        categ: Category.fish.name,
        price: 3.0,
        img: 'assets/images/img.png',
        options: ['Small', 'Medium', 'Large']),
  ];
});
// selected option per item (in-memory UI state).
// Map<itemId, selectedOption>
final selectedOptionsProvider =
    StateProvider<Map<String, String?>>((ref) => {});
final itemQuantityProvider = StateProvider.family<int, String>((ref, itemId) => 1);

// Filtered items provider (example: just return all, or you can map categories to filters)
final filteredMenuProvider = Provider<List<MenuItemModel>>((ref) {
  final all = ref.watch(menuProvider);

  final category = ref.watch(selectedCategoryProvider);
  if (category == Category.allMenu.name) return all;
  // Example filter (for demo purposes, filtering by name contains)
  return all
      .where((m) => m.name.contains(category!) || m.categ == category)
      .toList();
});
