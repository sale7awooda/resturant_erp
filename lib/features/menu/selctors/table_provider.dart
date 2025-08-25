import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Table { one, two, three, four, five, six, seven, eight, nine, ten }

// List of available categories
final tablesProvider = Provider<List<String>>((ref) {
  return [
    Table.one.name,
    Table.two.name,
    Table.three.name,
    Table.four.name,
    Table.five.name,
    Table.six.name,
    Table.seven.name,
    Table.eight.name,
    Table.nine.name,
    Table.ten.name,
  ];
});

// Selected table ('all menu' at first)
final selectedTableProvider = StateProvider<String?>((ref) => null);
