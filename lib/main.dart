import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'config/supabase_config.dart';
import 'providers/app_state.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await NotificationService.initialize();

  final appState = AppState();
  await appState.loadPreferences();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const KanjiApp(),
    ),
  );
}
