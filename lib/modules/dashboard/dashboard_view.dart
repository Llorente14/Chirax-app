import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_view.dart';
import '../finance/finance_view.dart'; // Nanti kita buat dummy-nya
import '../journey/journey_view.dart'; // Kalender perjalanan
import '../profile/profile_view.dart'; // Nanti kita buat dummy-nya
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
            type: BottomNavigationBarType.fixed, // Agar icon tidak bergeser
            showSelectedLabels:
                false, // Duolingo style: biasanya tanpa label teks
            showUnselectedLabels: false,

            selectedItemColor: AppColors.primary, // Pink saat aktif
            unselectedItemColor: Colors.grey.shade400, // Abu saat mati

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 30),
                activeIcon: Icon(
                  Icons.home_rounded,
                  size: 34,
                ), // Sedikit lebih besar saat aktif
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.savings_rounded, size: 30),
                activeIcon: Icon(Icons.savings_rounded, size: 34),
                label: 'Finance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded, size: 30),
                activeIcon: Icon(Icons.calendar_month_rounded, size: 34),
                label: 'Journey',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 30),
                activeIcon: Icon(Icons.person_rounded, size: 34),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
