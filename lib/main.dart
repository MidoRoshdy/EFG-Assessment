import 'package:currency_converter/app.dart';
import 'package:currency_converter/core/storage/app_database.dart';
import 'package:currency_converter/core/storage/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (prefs, database) = await (
    SharedPreferences.getInstance(),
    AppDatabase.open(),
  ).wait;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
      ],
      child: const App(),
    ),
  );
}
