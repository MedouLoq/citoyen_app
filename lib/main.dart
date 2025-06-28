import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/screens/splash_screen.dart';
import 'package:citoyen_app/providers/dashboard_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/problem/problem_list_screen.dart';
import 'screens/problem/report_problem_screen.dart';
import 'screens/complaint/submit_complaint_screen.dart';
import 'screens/problem/category_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/problem_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/notification_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:citoyen_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProblemProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('selectedLanguage');
    if (savedLanguageCode != null) {
      setState(() {
        _locale = Locale(savedLanguageCode);
      });
    }
  }

  void _updateLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citoyen App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'), // French
        Locale('ar'), // Arabic
      ],
      locale: _locale, // Use the dynamically set locale
      routes: {
        '/problem_list': (context) => ProblemListScreen(),
        '/report_problem': (context) => CategorySelectionScreen(),
        '/submit_complaint': (context) => SubmitComplaintScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
          primary: const Color(0xFF007AFF),
          secondary: const Color(0xFF5AC8FA),
          surface: Colors.white,
          background: const Color(0xFFF2F2F7),
          error: const Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge:
              GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.bold),
          displayMedium:
              GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.bold),
          displaySmall:
              GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge:
              GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600),
          headlineMedium:
              GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall:
              GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge:
              GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500),
          titleMedium: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
          titleSmall: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyLarge: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
          bodyMedium: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
          bodySmall: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
          labelLarge: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
          labelMedium: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          labelSmall: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
          titleTextStyle: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(onLocaleChanged: _updateLocale),
    );
  }
}
