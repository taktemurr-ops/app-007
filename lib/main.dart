import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'recipe_insights.dart';
import 'texts.dart';
import 'locale_number.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'recipes.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const Tarif360App()); }
class Tarif360App extends StatelessWidget {
  const Tarif360App({super.key});
  @override Widget build(BuildContext context) => MaterialApp(title: 'Tarif 360',
    supportedLocales: RecipeTexts.locales, localizationsDelegates: RecipeTexts.delegates,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffc66b2d))),
    home: const RecipeHome());
}
class RecipeHome extends StatefulWidget { const RecipeHome({super.key}); @override State<RecipeHome> createState() => _RecipeHomeState(); }
class _RecipeHomeState extends State<RecipeHome> {
  static const storage = FlutterSecureStorage();
  String _t(String key) => RecipeTexts.t(context, key);
  RecipeBook book = RecipeBook();
  bool loading = true;
  String? error;
  int tab = 0;
  final title = TextEditingController(), servings = TextEditingController(text: '2');
  final ingredientLines = TextEditingController(), stepLines = TextEditingController();
  final backupText = TextEditingController();
  DateTime selectedDay = DateTime.now();
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final raw = await storage.read(key: 'recipe_book_v1');
      if (mounted) setState(() { book = raw == null ? RecipeBook() : RecipeBook.importJson(raw); loading = false; error = null; }); }
    catch (_) { if (mounted) setState(() { error = 'Could not read private recipes'; loading = false; }); }
  }
  Future<void> _save() async {
    try { await storage.write(key: 'recipe_book_v1', value: book.exportJson()); if (mounted) setState(() {}); }
    catch (_) { _notice('Saving failed'); }
  }
  void _notice(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  void _add() {
    try {
      final ingredients = ingredientLines.text.split('\n').where((s) => s.trim().isNotEmpty).map((line) {
        final pieces = line.split('|');
        if (pieces.length != 3) throw const FormatException('Use name|quantity|unit');
        return Ingredient(name: pieces[0].trim(), quantity: parseMacroNumber(pieces[1].trim()) ?? -1, unit: pieces[2].trim());
      }).toList();
      final recipe = Recipe(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(),
        servings: parseMacroWholeNumber(servings.text.trim(), minimum: 1, maximum: 1000) ?? -1, ingredients: ingredients,
        steps: stepLines.text.split('\n').where((s) => s.trim().isNotEmpty).toList());
      book.add(recipe); title.clear(); ingredientLines.clear(); stepLines.clear(); _save();
    } catch (_) { _notice('Check recipe: title, servings, ingredients (name|quantity|unit), steps'); }
  }
  String dayKey(DateTime n) => '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  String get today => dayKey(selectedDay);
  Widget _list({bool favoritesOnly = false}) => ListView(children: [
    for (final r in book.recipes.where((r) => !favoritesOnly || book.favorites.contains(r.id))) Card(child: ListTile(
      title: Text(r.title), subtitle: Text('${r.servings} servings · ${r.ingredients.length} ingredients'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetail(recipe: r))),
      trailing: PopupMenuButton<String>(onSelected: (action) {
        if (action == 'favorite') book.toggleFavorite(r.id);
        if (action == 'plan') book.plan(today, r.id);
        if (action == 'delete') book.delete(r.id);
        _save();
      }, itemBuilder: (_) => [
        PopupMenuItem(value: 'favorite', child: Text(_t(book.favorites.contains(r.id) ? 'unfavorite' : 'favorite'))),
        PopupMenuItem(value: 'plan', child: Text(_t('addPlan'))),
        PopupMenuItem(value: 'delete', child: Text(_t('delete'))),
      ]))),
  ]);
  Widget _editor() => ListView(children: [
    TextField(controller: title, decoration: InputDecoration(labelText: _t('title'))),
    TextField(controller: servings, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _t('servings'))),
    TextField(controller: ingredientLines, maxLines: 6, decoration: InputDecoration(labelText: _t('ingredients'), hintText: 'Flour|200|g\nWater|150|ml')),
    TextField(controller: stepLines, maxLines: 6, decoration: InputDecoration(labelText: _t('steps'))),
    const SizedBox(height: 16), FilledButton(onPressed: _add, child: Text(_t('save'))),
  ]);
  Widget _plan() {
    final week = RecipeInsights.weekDates(selectedDay);
    final items = RecipeInsights.combinedShoppingList(book, week);
    return ListView(children: [
      Text(_t('weekly'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        for (final day in week) Padding(padding: const EdgeInsetsDirectional.only(end: 6),
          child: ChoiceChip(label: Text(day.substring(5)), selected: day == today,
            onSelected: (_) => setState(() => selectedDay = DateTime.parse(day))))
      ])),
      const SizedBox(height: 12),
      Text('Planned for $today', style: Theme.of(context).textTheme.titleMedium),
      for (final id in book.planned[today] ?? <String>[]) ListTile(
        title: Text(book.recipes.where((r) => r.id == id).firstOrNull?.title ?? 'Unknown'),
        trailing: IconButton(icon: const Icon(Icons.remove_circle_outline), tooltip: _t('removePlan'),
          onPressed: () { book.removePlanned(today, id); _save(); }),
      ),
      const Divider(), Text(_t('shopping'), style: Theme.of(context).textTheme.titleMedium),
      for (final item in items) ListTile(leading: const Icon(Icons.shopping_cart_outlined),
        title: Text('${item.name}: ${item.quantity.toStringAsFixed(1)} ${item.unit}')),
      OutlinedButton.icon(icon: const Icon(Icons.copy_outlined), label: Text(_t('copyShopping')),
        onPressed: () async {
          if (items.isEmpty) { _notice('No ingredients planned this week'); return; }
          await Clipboard.setData(ClipboardData(text: items.map((i) =>
            '${i.name} — ${i.quantity.toStringAsFixed(1)} ${i.unit}').join('\n')));
          _notice('Shopping list copied');
        }),
    ]);
  }

  Widget _dataControls() => ListView(children: [
    Text(_t('backups'), style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 12),
    Text(_t('privacyNote')),
    const SizedBox(height: 16),
    FilledButton.icon(icon: const Icon(Icons.copy_all_outlined), label: Text(_t('copyBackup')),
      onPressed: () async { await Clipboard.setData(ClipboardData(text: book.exportJson()));
        _notice('Backup copied. Keep it private.'); }),
    const SizedBox(height: 12),
    OutlinedButton.icon(icon: const Icon(Icons.restore), label: Text(_t('restore')),
      onPressed: () async {
        final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Replace all current recipes?'),
          content: SingleChildScrollView(child: TextField(controller: backupText, maxLines: 6,
            decoration: InputDecoration(labelText: _t('paste'), border: OutlineInputBorder()))),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_t('restore')))]));
        if (yes != true) return;
        try {
          final restored = RecipeBook.importJson(backupText.text);
          await storage.write(key: 'recipe_book_v1', value: restored.exportJson());
          if (mounted) setState(() => book = restored);
          _notice('Backup restored');
        } catch (_) { _notice('Invalid backup; existing recipes kept'); }
      }),
    const Divider(height: 32),
    OutlinedButton.icon(icon: const Icon(Icons.delete_forever_outlined), label: Text(_t('clear')),
      onPressed: () async {
        final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Delete all recipes, favorites and plans?'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_t('delete')))]));
        if (yes == true) { await storage.delete(key: 'recipe_book_v1');
          if (mounted) setState(() => book = RecipeBook()); }
      }),
  ]);
  @override void dispose() { for (final c in [title, servings, ingredientLines, stepLines, backupText]) { c.dispose(); } super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Tarif 360')),
    body: loading ? const Center(child: CircularProgressIndicator()) : error != null ? Center(child: TextButton(onPressed: _load, child: Text('$error — Retry'))) :
      Padding(padding: const EdgeInsets.all(12), child: [_list(), _editor(), _list(favoritesOnly: true), _plan(), _dataControls()][tab]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
      NavigationDestination(icon: Icon(Icons.menu_book), label: _t('recipes')),
      NavigationDestination(icon: Icon(Icons.add), label: _t('create')),
      NavigationDestination(icon: Icon(Icons.favorite_outline), label: _t('favorites')),
      NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: _t('plan')),
      NavigationDestination(icon: Icon(Icons.privacy_tip_outlined), label: _t('data')),
    ]));
}
class RecipeDetail extends StatefulWidget { const RecipeDetail({super.key, required this.recipe}); final Recipe recipe; @override State<RecipeDetail> createState() => _RecipeDetailState(); }
class _RecipeDetailState extends State<RecipeDetail> {
  late int servings = widget.recipe.servings;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.recipe.title)), body: ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [const Text('Servings'), IconButton(onPressed: servings > 1 ? () => setState(() => servings--) : null, icon: const Icon(Icons.remove)),
      Text('$servings'), IconButton(onPressed: servings < 1000 ? () => setState(() => servings++) : null, icon: const Icon(Icons.add))]),
    Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
    for (final i in widget.recipe.scaledIngredients(servings)) ListTile(title: Text(i.name), trailing: Text('${i.quantity.toStringAsFixed(1)} ${i.unit}')),
    Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
    for (var i = 0; i < widget.recipe.steps.length; i++) ListTile(leading: CircleAvatar(child: Text('${i+1}')), title: Text(widget.recipe.steps[i])),
  ]));
}
