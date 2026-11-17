import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RecipeTexts {
  const RecipeTexts._();
  static const locales = [Locale('tr'), Locale('en'), Locale('ar')];
  static const delegates = [GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate];
  static String t(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return (_all[lang] ?? _all['en']!)[key] ?? _all['en']![key] ?? key;
  }
  static const _all = <String, Map<String, String>>{
    'tr': {
      'recipes': 'Tarifler', 'create': 'Yeni Tarif', 'favorites': 'Favoriler',
      'plan': 'Plan', 'data': 'Veriler', 'title': 'Tarif adı', 'servings': 'Porsiyon',
      'ingredients': 'Malzemeler: ad|miktar|birim (her satıra bir malzeme)',
      'steps': 'Hazırlanışı (her satıra bir adım)', 'save': 'Tarifi kaydet',
      'favorite': 'Favoriye ekle', 'unfavorite': 'Favoriden çıkar',
      'addPlan': 'Bugünün planına ekle', 'delete': 'Sil',
      'weekly': 'Haftalık öğün planı', 'shopping': 'Haftalık alışveriş listesi',
      'copyShopping': 'Alışveriş listesini kopyala', 'removePlan': 'Plandan kaldır',
      'backups': 'Yerel veriler ve yedekler', 'copyBackup': 'JSON yedeğini kopyala',
      'restore': 'JSON yedeğini geri yükle', 'paste': 'JSON yedeğini yapıştır',
      'clear': 'Tüm yerel verileri sil', 'cancel': 'İptal',
      'weekPlan': 'Planlanan gün', 'instructions': 'Hazırlanışı',
      'privacyNote': 'Tarifler ve planlar cihazda kalır. Panodaki JSON şifreli değildir.',
    },
    'en': {
      'recipes': 'Recipes', 'create': 'Create', 'favorites': 'Favorites',
      'plan': 'Plan', 'data': 'Data', 'title': 'Recipe title', 'servings': 'Servings',
      'ingredients': 'Ingredients: name|quantity|unit (one per line)',
      'steps': 'Instructions (one step per line)', 'save': 'Save recipe',
      'favorite': 'Favorite', 'unfavorite': 'Unfavorite',
      'addPlan': 'Add to today’s plan', 'delete': 'Delete',
      'weekly': 'Weekly meal planner', 'shopping': 'Combined weekly shopping list',
      'copyShopping': 'Copy shopping list', 'removePlan': 'Remove planned recipe',
      'backups': 'Local data and backups', 'copyBackup': 'Copy JSON backup',
      'restore': 'Restore JSON backup', 'paste': 'Paste JSON',
      'clear': 'Delete all local data', 'cancel': 'Cancel',
      'weekPlan': 'Planned for', 'instructions': 'Instructions',
      'privacyNote': 'Recipes and plans stay on this device. Clipboard JSON is not encrypted.',
    },
    'ar': {
      'recipes': 'الوصفات', 'create': 'إضافة وصفة', 'favorites': 'المفضلة',
      'plan': 'الخطة', 'data': 'البيانات', 'title': 'عنوان الوصفة', 'servings': 'الحصص',
      'ingredients': 'المكونات: الاسم|الكمية|الوحدة (سطر لكل مكون)',
      'steps': 'خطوات التحضير (سطر لكل خطوة)', 'save': 'حفظ الوصفة',
      'favorite': 'إضافة إلى المفضلة', 'unfavorite': 'إزالة من المفضلة',
      'addPlan': 'إضافة لخطة اليوم', 'delete': 'حذف',
      'weekly': 'خطة الوجبات الأسبوعية', 'shopping': 'قائمة التسوق الأسبوعية',
      'copyShopping': 'نسخ قائمة التسوق', 'removePlan': 'إزالة من الخطة',
      'backups': 'البيانات والنسخ الاحتياطي', 'copyBackup': 'نسخ بيانات JSON',
      'restore': 'استعادة نسخة JSON', 'paste': 'لصق بيانات JSON',
      'clear': 'حذف البيانات المحلية', 'cancel': 'إلغاء',
      'weekPlan': 'الخطة ليوم', 'instructions': 'طريقة التحضير',
      'privacyNote': 'تبقى وصفاتك على جهازك. بيانات JSON في الحافظة غير مشفرة.',
    },
  };
}
