import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../home/home_controller.dart';
import '../journey/journey_controller.dart';
import '../finance/finance_controller.dart';
import '../profile/profile_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard Controller
    Get.lazyPut<DashboardController>(() => DashboardController());

    // Home Controller - untuk gamification features
    Get.lazyPut<HomeController>(() => HomeController());

    // Journey Controller - untuk kalender shared journey
    Get.lazyPut<JourneyController>(() => JourneyController());

    // Finance Controller - untuk tabungan bersama
    Get.lazyPut<FinanceController>(() => FinanceController());

    // Profile Controller - untuk profil & settings
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
