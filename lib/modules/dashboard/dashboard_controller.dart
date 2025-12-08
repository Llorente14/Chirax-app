import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Variable reactive untuk menyimpan index halaman saat ini (0 = Home)
  var tabIndex = 0.obs;

  // Fungsi untuk ganti tab
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
