class MoodOption {
  final int score;
  final String emoji;
  final String label;

  const MoodOption({
    required this.score,
    required this.emoji,
    required this.label,
  });

  static const List<MoodOption> all = [
    MoodOption(score: 1, emoji: '😡', label: 'Very Negative'),
    MoodOption(score: 2, emoji: '🙁', label: 'Negative'),
    MoodOption(score: 3, emoji: '😐', label: 'Neutral'),
    MoodOption(score: 4, emoji: '🙂', label: 'Positive'),
    MoodOption(score: 5, emoji: '😄', label: 'Very Positive'),
  ];
}

