import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../../modules/profile/profile_controller.dart';

/// SoundHelper - Static helper untuk memutar Sound Effects
/// Menggunakan AudioPlayer terpisah untuk setiap jenis suara
/// agar tidak saling memotong
class SoundHelper {
  // Separate players for each sound type to prevent audio cutting
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _swipePlayer = AudioPlayer();
  static final AudioPlayer _coinsPlayer = AudioPlayer();
  static final AudioPlayer _ignitePlayer = AudioPlayer();
  static final AudioPlayer _magicPlayer = AudioPlayer();
  static final AudioPlayer _tadaPlayer = AudioPlayer();
  static final AudioPlayer _errorPlayer = AudioPlayer();
  static final AudioPlayer _popPlayer = AudioPlayer();
  static final AudioPlayer _introPlayer = AudioPlayer();

  /// Check if sound is enabled from ProfileController
  static bool get _isEnabled {
    try {
      final controller = Get.find<ProfileController>();
      return controller.isSoundEnabled.value;
    } catch (e) {
      // ProfileController not registered yet, default to enabled
      return true;
    }
  }

  /// Internal play function dengan mode lowLatency
  static Future<void> _play(AudioPlayer player, String file) async {
    if (!_isEnabled) return;

    try {
      await player.stop();
      await player.play(
        AssetSource('sounds/$file'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // Silently fail jika audio tidak tersedia
    }
  }

  /// Play click sound - untuk button tap
  static Future<void> playClick() => _play(_clickPlayer, 'click.mp3');

  /// Play swipe sound - untuk bottom sheet & gestures
  static Future<void> playSwipe() => _play(_swipePlayer, 'swipe.mp3');

  /// Play coins sound - untuk tabungan & rewards
  static Future<void> playCoins() => _play(_coinsPlayer, 'coins.mp3');

  /// Play ignite sound - untuk check-in sukses
  static Future<void> playIgnite() => _play(_ignitePlayer, 'ignite.mp3');

  /// Play magic sound - untuk poke/special actions
  static Future<void> playMagic() => _play(_magicPlayer, 'magic.mp3');

  /// Play tada sound - untuk celebrations
  static Future<void> playTada() => _play(_tadaPlayer, 'tada.mp3');

  /// Play error sound - untuk delete & validation errors
  static Future<void> playError() => _play(_errorPlayer, 'error.mp3');

  /// Play pop sound - untuk calendar swipe & back buttons
  static Future<void> playPop() => _play(_popPlayer, 'pop.mp3');

  /// Play intro sound - untuk splash screen
  static Future<void> playIntro() => _play(_introPlayer, 'intro.mp3');
}
