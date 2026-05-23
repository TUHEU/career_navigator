import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/job_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'router/app_router.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Career Navigator',
      theme: _buildTheme(isDark),
      onGenerateRoute: generateRoute,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(bool isDark) {
    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final cardColor = AppColors.card(isDark);
    final txtPrimary = AppColors.text(isDark);
    final txtSecondary = AppColors.textSecondary(isDark);
    final txtMuted = AppColors.textMuted(isDark);
    final fill = AppColors.inputFill(isDark);
    final border = AppColors.border(isDark);
    final cyan = AppColors.cyan(isDark);

    const r15 = BorderRadius.all(Radius.circular(15));
    const r12 = BorderRadius.all(Radius.circular(12));

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,

      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      primaryColor: cyan,

      // ColorScheme — onSurface drives default text colour everywhere
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: cyan,
        onPrimary: Colors.black, // black on cyan for both modes
        secondary: cyan,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: txtPrimary, // ← this makes Text() use dark colour by default
      ),

      // TextTheme — every style explicitly dark in light mode
      textTheme: TextTheme(
        displayLarge: TextStyle(color: txtPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
          color: txtPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(color: txtPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(
          color: txtPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: txtPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: txtPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(color: txtPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: txtPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: txtPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: txtPrimary),
        bodyMedium: TextStyle(color: txtPrimary),
        bodySmall: TextStyle(color: txtSecondary),
        labelLarge: TextStyle(color: txtPrimary, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: txtSecondary),
        labelSmall: TextStyle(color: txtMuted),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: txtPrimary,
        iconTheme: IconThemeData(color: txtPrimary),
        actionsIconTheme: IconThemeData(color: txtPrimary),
        titleTextStyle: TextStyle(
          color: txtPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      // Icons
      iconTheme: IconThemeData(color: txtPrimary),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: Colors.black, // black on #00B8D4 cyan
          shape: RoundedRectangleBorder(borderRadius: r15),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txtPrimary,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: r15),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cyan),
      ),

      // Input / TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fill,
        labelStyle: TextStyle(
          color: txtSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: txtMuted, fontSize: 14),
        prefixIconColor: cyan,
        suffixIconColor: cyan,
        border: OutlineInputBorder(
          borderRadius: r15,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: r15,
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: r15,
          borderSide: BorderSide(color: cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: r15,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: r15,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? cyan : Colors.grey,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? cyan.withOpacity(0.4)
              : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade400),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        labelStyle: TextStyle(
          color: txtPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: r12),
        selectedColor: cyan.withOpacity(0.2),
        checkmarkColor: cyan,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: r12),
        backgroundColor: isDark ? AppColors.darkCard : const Color(0xFF1C2333),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // BottomNavigationBar — FIX: explicit dark colours so icons/labels show
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: cyan,
        unselectedItemColor: isDark
            ? const Color(0xFF8899BB)
            : AppColors.lightTextMuted,
        selectedLabelStyle: TextStyle(
          color: cyan,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          color: isDark ? const Color(0xFF8899BB) : AppColors.lightTextMuted,
          fontSize: 11,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // NavigationBar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: cyan.withOpacity(0.15),
        iconTheme: MaterialStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(MaterialState.selected)
                ? cyan
                : (isDark ? const Color(0xFF8899BB) : AppColors.lightTextMuted),
            size: 24,
          ),
        ),
        labelTextStyle: MaterialStateProperty.resolveWith(
          (s) => TextStyle(
            color: s.contains(MaterialState.selected)
                ? cyan
                : (isDark ? const Color(0xFF8899BB) : AppColors.lightTextMuted),
            fontSize: 11,
            fontWeight: s.contains(MaterialState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        textColor: txtPrimary,
        iconColor: isDark ? const Color(0xFF8899BB) : AppColors.lightTextMuted,
        tileColor: Colors.transparent,
        subtitleTextStyle: TextStyle(color: txtSecondary, fontSize: 13),
      ),

      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: txtPrimary),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStatePropertyAll(surface),
        ),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        textStyle: TextStyle(color: txtPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: cyan,
        unselectedLabelColor: txtMuted,
        indicatorColor: cyan,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cyan,
        foregroundColor: Colors.black, // black on #00B8D4 cyan
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? cyan : Colors.transparent,
        ),
        checkColor: MaterialStatePropertyAll(
          isDark ? Colors.black : Colors.white,
        ),
        side: BorderSide(color: border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? cyan : txtMuted,
        ),
      ),
    );
  }
}
