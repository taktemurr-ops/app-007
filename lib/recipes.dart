import 'dart:convert';

class Ingredient {
  const Ingredient({required this.name, required this.quantity, required this.unit});
  final String name, unit;
  final double quantity;
  void validate() {
    if (name.trim().isEmpty || name.length > 100 || unit.trim().isEmpty || unit.length > 24 ||
        !quantity.isFinite || quantity <= 0 || quantity > 1000000) throw ArgumentError('Invalid ingredient');
  }
  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'unit': unit};
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(name: json['name'] as String,
    quantity: (json['quantity'] as num).toDouble(), unit: json['unit'] as String)..validate();
}

class Recipe {
  const Recipe({required this.id, required this.title, required this.servings,
    required this.ingredients, required this.steps, this.tags = const []});
  final String id, title;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps, tags;
  void validate() {
    if (id.isEmpty || title.trim().isEmpty || title.length > 120 || servings < 1 || servings > 1000 ||
        ingredients.isEmpty || ingredients.length > 100 || steps.isEmpty || steps.length > 100 ||
        steps.any((s) => s.trim().isEmpty || s.length > 2000) || tags.length > 30) throw ArgumentError('Invalid recipe');
    for (final ingredient in ingredients) { ingredient.validate(); }
  }
  List<Ingredient> scaledIngredients(int desiredServings) {
    if (desiredServings < 1 || desiredServings > 1000) throw ArgumentError('Invalid servings');
    return ingredients.map((i) => Ingredient(name: i.name,
      quantity: i.quantity * desiredServings / servings, unit: i.unit)).toList();
  }
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'servings': servings,
    'ingredients': ingredients.map((e) => e.toJson()).toList(), 'steps': steps, 'tags': tags};
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String, title: json['title'] as String, servings: (json['servings'] as num).toInt(),
    ingredients: (json['ingredients'] as List).map((e) => Ingredient.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    steps: List<String>.from(json['steps'] as List), tags: List<String>.from(json['tags'] as List? ?? []))..validate();
}

class RecipeBook {
  final recipes = <Recipe>[];
  final favorites = <String>{};
  final planned = <String, List<String>>{}; // yyyy-mm-dd -> recipe ids
  void add(Recipe recipe) { recipe.validate(); if (recipes.any((r) => r.id == recipe.id)) throw StateError('Duplicate recipe'); recipes.add(recipe); }
  void delete(String id) { recipes.removeWhere((r) => r.id == id); favorites.remove(id); for (final list in planned.values) { list.removeWhere((value) => value == id); } }
  void toggleFavorite(String id) {
    if (!recipes.any((r) => r.id == id)) throw ArgumentError('Unknown recipe');
    if (!favorites.add(id)) favorites.remove(id);
  }
  void plan(String date, String id) {
    if (DateTime.tryParse(date) == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) throw ArgumentError('Invalid date');
    if (!recipes.any((r) => r.id == id)) throw ArgumentError('Unknown recipe');
    (planned[date] ??= []).add(id);
  }
  void removePlanned(String date, String recipeId) {
    planned[date]?.remove(recipeId);
    if (planned[date]?.isEmpty ?? false) planned.remove(date);
  }
  List<Ingredient> shoppingList(String date, {int servingsMultiplier = 1}) {
    if (servingsMultiplier < 1 || servingsMultiplier > 1000) throw ArgumentError('Invalid multiplier');
    final aggregated = <String, double>{};
    final names = <String, Ingredient>{};
    for (final id in planned[date] ?? <String>[]) {
      final recipe = recipes.where((r) => r.id == id).firstOrNull;
      if (recipe == null) continue;
      for (final ingredient in recipe.scaledIngredients(recipe.servings * servingsMultiplier)) {
        final key = '${ingredient.name.trim().toLowerCase()}|${ingredient.unit.trim().toLowerCase()}';
        aggregated.update(key, (v) => v + ingredient.quantity, ifAbsent: () => ingredient.quantity);
        names[key] = ingredient;
      }
    }
    return aggregated.entries.map((e) => Ingredient(name: names[e.key]!.name, quantity: e.value, unit: names[e.key]!.unit)).toList();
  }
  String exportJson() => jsonEncode({'schemaVersion': 1, 'recipes': recipes.map((e) => e.toJson()).toList(),
    'favorites': favorites.toList(), 'planned': planned});
  static RecipeBook importJson(String source) {
    if (source.length > 2000000) throw const FormatException('Backup too large');
    final data = Map<String, dynamic>.from(jsonDecode(source) as Map);
    if (data['schemaVersion'] != 1) throw const FormatException('Unsupported schema');
    if (data['recipes'] is! List || (data['recipes'] as List).length > 10000 ||
        data['favorites'] is! List || (data['favorites'] as List).length > 10000 ||
        data['planned'] is! Map || (data['planned'] as Map).length > 3660) {
      throw const FormatException('Malformed or oversized backup');
    }
    final result = RecipeBook();
    for (final raw in data['recipes'] as List) { result.add(Recipe.fromJson(Map<String, dynamic>.from(raw as Map))); }
    for (final id in data['favorites'] as List) { result.toggleFavorite(id as String); }
    for (final entry in (data['planned'] as Map).entries) {
      for (final id in entry.value as List) { result.plan(entry.key as String, id as String); }
    }
    return result;
  }
}
