import 'package:flutter/material.dart';

/// JourneyEvent - Model untuk event di kalender
class JourneyEvent {
  final String id;
  final String title;
  final DateTime date;
  final String category; // 'date', 'anniversary', 'trip', 'other'
  final Color color;
  final String icon; // Emoji string
  final bool isSurprise; // Apakah ini event kejutan
  final String? createdBy; // 'me' atau 'partner'

  JourneyEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.color,
    required this.icon,
    this.isSurprise = false,
    this.createdBy,
  });

  /// Factory untuk membuat event dengan kategori preset
  factory JourneyEvent.date({
    required String id,
    required String title,
    required DateTime date,
    bool isSurprise = false,
    String? createdBy,
  }) {
    return JourneyEvent(
      id: id,
      title: title,
      date: date,
      category: 'date',
      color: const Color(0xFFF399D1), // Pink
      icon: '❤️',
      isSurprise: isSurprise,
      createdBy: createdBy,
    );
  }

  factory JourneyEvent.anniversary({
    required String id,
    required String title,
    required DateTime date,
    bool isSurprise = false,
    String? createdBy,
  }) {
    return JourneyEvent(
      id: id,
      title: title,
      date: date,
      category: 'anniversary',
      color: const Color(0xFFFF6B6B), // Red
      icon: '🎂',
      isSurprise: isSurprise,
      createdBy: createdBy,
    );
  }

  factory JourneyEvent.trip({
    required String id,
    required String title,
    required DateTime date,
    bool isSurprise = false,
    String? createdBy,
  }) {
    return JourneyEvent(
      id: id,
      title: title,
      date: date,
      category: 'trip',
      color: const Color(0xFF1899D6), // Blue
      icon: '✈️',
      isSurprise: isSurprise,
      createdBy: createdBy,
    );
  }

  factory JourneyEvent.other({
    required String id,
    required String title,
    required DateTime date,
    String icon = '📌',
    bool isSurprise = false,
    String? createdBy,
  }) {
    return JourneyEvent(
      id: id,
      title: title,
      date: date,
      category: 'other',
      color: const Color(0xFF58CC02), // Green
      icon: icon,
      isSurprise: isSurprise,
      createdBy: createdBy,
    );
  }

  /// Warna untuk surprise events
  static const Color surpriseColor = Color(0xFF9B59B6); // Ungu
  static const Color surpriseGold = Color(0xFFFFD700); // Emas
}

/// Kategori event yang tersedia
class EventCategory {
  final String id;
  final String label;
  final String icon;
  final Color color;

  const EventCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const List<EventCategory> categories = [
    EventCategory(
      id: 'date',
      label: 'Date Night',
      icon: '❤️',
      color: Color(0xFFF399D1),
    ),
    EventCategory(
      id: 'anniversary',
      label: 'Anniversary',
      icon: '🎂',
      color: Color(0xFFFF6B6B),
    ),
    EventCategory(
      id: 'trip',
      label: 'Trip',
      icon: '✈️',
      color: Color(0xFF1899D6),
    ),
    EventCategory(
      id: 'other',
      label: 'Other',
      icon: '📌',
      color: Color(0xFF58CC02),
    ),
  ];
}
