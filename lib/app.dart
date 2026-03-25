import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

class KanjiApp extends StatefulWidget {
  const KanjiApp({super.key});

  @override
  State<KanjiApp> createState() => _KanjiAppState();
}

class _KanjiAppState extends State<KanjiApp> {
  String? _cachedFontFamily;
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;

  static const _appBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );

  void _rebuildThemes(String fontFamily) {
    _cachedFontFamily = fontFamily;
    _lightTheme = ThemeData(
      colorSchemeSeed: const Color(0xFF7B8FAD),
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: _appBarTheme,
      textTheme: GoogleFonts.getTextTheme(fontFamily),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FastSlideTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _FastSlideTransitionBuilder(),
        },
      ),
    );
    _darkTheme = ThemeData(
      colorSchemeSeed: const Color(0xFF7B8FAD),
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: _appBarTheme,
      textTheme: GoogleFonts.getTextTheme(
        fontFamily,
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FastSlideTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _FastSlideTransitionBuilder(),
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final fontFamily = context.read<AppState>().fontFamily;
    _rebuildThemes(fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.fontFamily != _cachedFontFamily) {
      _rebuildThemes(appState.fontFamily);
    }

    return MaterialApp(
      title: 'SSW Kanji',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        // AnimatedContainer smooths the gradient transition during theme switch
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF1A2332), Color(0xFF0F1923)]
                  : const [Color(0xFFCDD5DE), Color(0xFFB0BCC9)],
            ),
          ),
          child: child,
        );
      },
      home: const HomeScreen(),
    );
  }
}

/// Fast 200ms slide+fade page transition for snappy navigation
class _FastSlideTransitionBuilder extends PageTransitionsBuilder {
  const _FastSlideTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use a faster curve and shorter effective duration feel
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
