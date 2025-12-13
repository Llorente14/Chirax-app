import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_colors.dart';
import 'data/services/auth_service.dart';
import 'data/services/database_service.dart';
import 'data/services/notification_service.dart';
import 'modules/auth/login_view.dart';
import 'modules/auth/pairing_view.dart';
import 'modules/auth/setup_profile_view.dart';
import 'modules/auth/splash_view.dart';
import 'modules/dashboard/dashboard_binding.dart';
import 'modules/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize date formatting
  await initializeDateFormatting('id', null);

  // Initialize notification service
  await NotificationService.init();

  // Initialize services
  Get.put(AuthService());
  Get.put(DatabaseService());

  runApp(const ChiraxApp());
}

class ChiraxApp extends StatelessWidget {
  const ChiraxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chirax',
      debugShowCheckedModeBanner: false,

      // Theme dengan Google Fonts Nunito (bulat dan friendly seperti Duolingo)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.offWhite,

        // Typography menggunakan Nunito
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
      ),

      // Named routes for navigation
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/setup-profile', page: () => const SetupProfileView()),
        GetPage(name: '/pairing', page: () => const PairingView()),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardView(),
          binding: DashboardBinding(),
        ),
      ],

      // Initial binding untuk Dashboard (untuk direct navigation)
      initialBinding: DashboardBinding(),

      // Splash screen -> checks auth and navigates
      home: const SplashView(),
    );
  }
}
