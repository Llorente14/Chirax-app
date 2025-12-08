/// DailyMood - Model untuk tracking mood harian
class DailyMood {
  final DateTime date;
  final String moodIcon; // Emoji
  final String? note;

  DailyMood({required this.date, required this.moodIcon, this.note});
}

/// Opsi mood yang tersedia
class MoodOption {
  final String icon;
  final String label;

  const MoodOption({required this.icon, required this.label});

  static const List<MoodOption> options = [
    MoodOption(icon: '😄', label: 'Happy'),
    MoodOption(icon: '🥰', label: 'In Love'),
    MoodOption(icon: '😊', label: 'Good'),
    MoodOption(icon: '😐', label: 'Okay'),
    MoodOption(icon: '😢', label: 'Sad'),
    MoodOption(icon: '😡', label: 'Angry'),
  ];
}
