import 'package:flutter_test/flutter_test.dart';
import 'package:tarif_360/recipe_insights.dart';
import 'package:tarif_360/recipes.dart';

void main() {
  const salad = Recipe(id: 'salad', title: 'Salad', servings: 2,
    ingredients: [Ingredient(name: 'Tomato', quantity: 100, unit: 'g')], steps: ['Chop']);
  test('week starts Monday and spans seven different days', () {
    final dates = RecipeInsights.weekDates(DateTime(2026, 11, 17));
    expect(dates.length, 7);
    expect(dates.first, '2026-11-16');
    expect(dates.last, '2026-11-22');
  });
  test('weekly ingredient list aggregates across planned dates', () {
    final book = RecipeBook()..add(salad);
    book.plan('2026-11-16', 'salad');
    book.plan('2026-11-17', 'salad');
    final dates = RecipeInsights.weekDates(DateTime(2026, 11, 17));
    expect(RecipeInsights.plannedServings(book, dates), 2);
    expect(RecipeInsights.combinedShoppingList(book, dates).single.quantity, 200);
    book.removePlanned('2026-11-16', 'salad');
    expect(RecipeInsights.plannedServings(book, dates), 1);
  });
  test('oversized exports and invalid shopping multiplier are rejected', () {
    expect(() => RecipeBook.importJson(List.filled(2000001, 'x').join()), throwsFormatException);
    expect(() => (RecipeBook()..add(salad)).shoppingList('2026-11-17', servingsMultiplier: 0), throwsArgumentError);
  });
}
