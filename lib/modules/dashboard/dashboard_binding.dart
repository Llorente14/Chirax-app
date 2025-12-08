import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../home/home_controller.dart';
import '../journey/journey_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard Controller
    Get.lazyPut<DashboardController>(() => DashboardController());

    // Home Controller - untuk gamification features
    Get.lazyPut<HomeController>(() => HomeController());

    // Journey Controller - untuk kalender shared journey
    Get.lazyPut<JourneyController>(() => JourneyController());

    // Nanti tambahkan controller lain di sini:
    // Get.lazyPut<FinanceController>(() => FinanceController());
    // Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
