import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Only provider, not Riverpod
import 'package:citoyen_app/screens/splash_screen.dart'; // Will be created next

import 'package:citoyen_app/providers/dashboard_provider.dart'; // Import your provider
import 'package:intl/date_symbol_data_local.dart';
import 'screens/problem/problem_list_screen.dart';
import 'screens/problem/report_problem_screen.dart';
import 'screens/problem/category_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/problem_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProblemProvider()),
         ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // Add other providers here
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citoyen App',
      debugShowCheckedModeBanner: false,
      // In your main.dart or routes configuration
routes: {
  '/problem_list': (context) => ProblemListScreen(),
  '/report_problem': (context) => CategorySelectionScreen(),
  // Add other routes as needed
},

      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define a modern color scheme (example)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Example primary blue
          brightness: Brightness.light,
          primary: const Color(0xFF007AFF),
          secondary: const Color(0xFF5AC8FA), // Example secondary light blue
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
          displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600),
          headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500),
          titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
          titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
          bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
          bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
          labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
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
      home: const SplashScreen(), // Initial screen
      // Define routes here later
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/dashboard': (context) => DashboardScreen(),
      // },
    );
  }
}

