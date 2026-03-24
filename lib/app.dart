import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'SSW Kanji',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7B8FAD),
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        textTheme: GoogleFonts.getTextTheme(appState.fontFamily),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF7B8FAD),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        textTheme: GoogleFonts.getTextTheme(
          appState.fontFamily,
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1A2332), const Color(0xFF0F1923)]
                  : [const Color(0xFFCDD5DE), const Color(0xFFB0BCC9)],
            ),
          ),
          child: child,
        );
      },
      home: const HomeScreen(),
    );
  }
}
