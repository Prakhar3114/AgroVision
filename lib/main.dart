// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase — must be before runApp
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AgroVisionApp());
}

class AgroVisionApp extends StatelessWidget {
  const AgroVisionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroVision',
      theme: _buildDarkTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const MainShell(),
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF060D09),
      primaryColor: const Color(0xFF00DC64),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00DC64),
        secondary: Color(0xFF00DC64),
        surface: Color(0xFF0D1A12),
        background: Color(0xFF060D09),
        error: Color(0xFFFF5252),
      ),
      fontFamily: 'Sora',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Color(0xFFE8FFF2),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5),
        bodyLarge: TextStyle(color: Color(0xFFE8FFF2)),
        bodyMedium: TextStyle(color: Color(0xFF8AB89A)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00DC64),
          foregroundColor: const Color(0xFF060D09),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00DC64),
          side: const BorderSide(color: Color(0xFF00DC64), width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1A12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1A3D28))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1A3D28))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF00DC64), width: 1.5)),
        labelStyle:
            const TextStyle(color: Color(0xFF4D7A5E)),
        hintStyle:
            const TextStyle(color: Color(0xFF3D6B50)),
        prefixIconColor: const Color(0xFF4D7A5E),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0D1A12),
        contentTextStyle:
            const TextStyle(color: Color(0xFFE8FFF2)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: const Color(0xFF1A3D28),
      iconTheme:
          const IconThemeData(color: Color(0xFF4D7A5E)),
    );
  }
}

// ─── Bottom Nav Shell ─────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F0D),
        border:
            Border(top: BorderSide(color: Color(0xFF1A2E22), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.biotech_outlined, Icons.biotech,
                  'Scanner'),
              _navItem(1, Icons.history_outlined, Icons.history,
                  'History'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon,
      String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00DC64).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: const Color(0xFF00DC64).withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive
                    ? const Color(0xFF00DC64)
                    : const Color(0xFF3D6B50),
                size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF00DC64)
                      : const Color(0xFF3D6B50),
                  letterSpacing: 0.5,
                )),
          ],
        ),
      ),
    );
  }
}