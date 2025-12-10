import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_colors.dart';
import 'modules/auth/splash_view.dart';
import 'modules/dashboard/dashboard_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
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

      // Initial binding untuk Dashboard
      initialBinding: DashboardBinding(),

      // Splash screen -> navigates to Dashboard
      home: const SplashView(),
    );
  }
}
