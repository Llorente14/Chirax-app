import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_helper.dart';
import '../home/home_view.dart';
import '../finance/finance_view.dart';
import '../journey/journey_view.dart';
import '../profile/profile_view.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND UTAMA APLIKASI
      backgroundColor: AppColors.offWhite,

      // BODY MENGGUNAKAN OBX AGAR BERUBAH SAAT TAB DIKLIK
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(), // Index 0
            FinanceView(), // Index 1
            JourneyView(), // Index 2 - Kalender
            ProfileView(), // Index 3
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR (Gaya Chunky/Duolingo Simple)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
        ),
        child: Obx(
          () => BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,

            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,

            items: [
              BottomNavigationBarItem(
                icon: PhosphorIcon(AppIcons.navHome, size: 28),
                activeIcon: PhosphorIcon(AppIcons.navHome, size: 32),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: PhosphorIcon(AppIcons.navFinance, size: 28),
                activeIcon: PhosphorIcon(AppIcons.navFinance, size: 32),
                label: 'Finance',
              ),
              BottomNavigationBarItem(
                icon: PhosphorIcon(AppIcons.navJourney, size: 28),
                activeIcon: PhosphorIcon(AppIcons.navJourney, size: 32),
                label: 'Journey',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 28),
                activeIcon: Icon(Icons.person_rounded, size: 32),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
