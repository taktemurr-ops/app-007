import 'recipes.dart';

/// Date-safe, offline-only reporting for planned recipes.
class RecipeInsights {
  const RecipeInsights._();
  static List<String> weekDates(DateTime day) {
    final local = DateTime(day.year, day.month, day.day);
    final monday = local.subtract(Duration(days: local.weekday - 1));
    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
  }

  static int plannedServings(RecipeBook book, Iterable<String> dates) =>
      dates.fold(0, (count, date) => count + (book.planned[date]?.length ?? 0));

  static List<Ingredient> combinedShoppingList(RecipeBook book, Iterable<String> days) {
    final total = <String, double>{};
    final original = <String, Ingredient>{};
    for (final day in days) {
      for (final ingredient in book.shoppingList(day)) {
        final key = '${ingredient.name.trim().toLowerCase()}|${ingredient.unit.trim().toLowerCase()}';
        total.update(key, (quantity) => quantity + ingredient.quantity,
            ifAbsent: () => ingredient.quantity);
        original[key] = ingredient;
      }
    }
    final keys = total.keys.toList()..sort();
    return keys.map((key) => Ingredient(name: original[key]!.name,
      quantity: total[key]!, unit: original[key]!.unit)).toList();
  }
}
