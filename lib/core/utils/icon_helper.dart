import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// AppIcons - Centralized icon mapping for consistent Phosphor Icons usage
/// Use string keys to store in Firestore, render with getIcon()
class AppIcons {
  /// Category icons for Finance goals and Journey events
  /// Keys are stored in Firestore, values are Phosphor IconData
  static final Map<String, IconData> categoryIcons = {
    'house': PhosphorIconsFill.house,
    'transport': PhosphorIconsFill.car,
    'trip': PhosphorIconsFill.airplane,
    'love': PhosphorIconsFill.heart,
    'tech': PhosphorIconsFill.laptop,
    'phone': PhosphorIconsFill.deviceMobile,
    'food': PhosphorIconsFill.hamburger,
    'health': PhosphorIconsFill.firstAid,
    'education': PhosphorIconsFill.graduationCap,
    'vacation': PhosphorIconsFill.island,
    'savings': PhosphorIconsFill.piggyBank,
    'game': PhosphorIconsFill.gameController,
    'shopping': PhosphorIconsFill.shoppingBag,
    'movie': PhosphorIconsFill.filmStrip,
    'gift': PhosphorIconsFill.gift,
    'other': PhosphorIconsFill.pushPin,
  };

  /// Get icon list for picker grid (returns list of entries)
  static List<MapEntry<String, IconData>> get iconList =>
      categoryIcons.entries.toList();

  /// Get IconData from key, returns star if not found
  /// Handles legacy emoji data gracefully
  static IconData getIcon(String? key) {
    if (key == null || key.isEmpty) {
      return PhosphorIconsFill.star;
    }
    return categoryIcons[key] ?? PhosphorIconsFill.star;
  }

  /// Bottom Navigation Icons
  static PhosphorIconData get navHome => PhosphorIconsFill.house;
  static PhosphorIconData get navFinance => PhosphorIconsFill.piggyBank;
  static PhosphorIconData get navJourney => PhosphorIconsFill.calendarHeart;
  static PhosphorIconData get navProfile => PhosphorIconsFill.userCircle;

  /// Settings Icons
  static PhosphorIconData get sound => PhosphorIconsFill.speakerHigh;
  static PhosphorIconData get notification => PhosphorIconsFill.bell;
  static PhosphorIconData get fingerprint => PhosphorIconsFill.fingerprint;
  static PhosphorIconData get heart => PhosphorIconsFill.heart;
  static PhosphorIconData get edit => PhosphorIconsFill.pencilSimple;
  static PhosphorIconData get logout => PhosphorIconsFill.signOut;
  static PhosphorIconData get settings => PhosphorIconsFill.gear;
  static PhosphorIconData get arrowBack => PhosphorIconsFill.arrowLeft;
  static PhosphorIconData get check => PhosphorIconsFill.check;
  static PhosphorIconData get calendar => PhosphorIconsFill.calendarBlank;
  static PhosphorIconData get add => PhosphorIconsFill.plus;
  static PhosphorIconData get save => PhosphorIconsFill.floppyDisk;
  static PhosphorIconData get trash => PhosphorIconsFill.trash;
}
