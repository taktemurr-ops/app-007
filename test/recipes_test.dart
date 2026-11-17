import 'package:flutter_test/flutter_test.dart';
import 'package:tarif_360/recipes.dart';
void main() {
  const recipe = Recipe(id: 'r1', title: 'Bread', servings: 2,
    ingredients: [Ingredient(name: 'Flour', quantity: 200, unit: 'g')], steps: ['Mix', 'Bake']);
  test('scale ingredient quantities', () {
    expect(recipe.scaledIngredients(4).single.quantity, 400);
    expect(() => recipe.scaledIngredients(0), throwsArgumentError);
  });
  test('shopping list combines repeated planned recipes', () {
    final book = RecipeBook()..add(recipe);
    book.plan('2026-11-17', 'r1'); book.plan('2026-11-17', 'r1');
    expect(book.shoppingList('2026-11-17').single.quantity, 400);
  });
  test('favorites, plans and export roundtrip', () {
    final book = RecipeBook()..add(recipe);
    book.toggleFavorite('r1'); book.plan('2026-11-17', 'r1');
    final restored = RecipeBook.importJson(book.exportJson());
    expect(restored.favorites.contains('r1'), true);
    expect(restored.shoppingList('2026-11-17').single.name, 'Flour');
  });
  test('invalid ingredient rejected', () {
    expect(() => const Ingredient(name: 'X', quantity: -1, unit: 'g').validate(), throwsArgumentError);
  });
}
