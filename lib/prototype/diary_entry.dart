import 'package:flutter/material.dart';

enum DiaryMood {
  happy('행복', '😊', Color(0xFF45A36B)),
  normal('보통', '🙂', Color(0xFFE2B84B)),
  tired('피곤', '😴', Color(0xFFF2994A)),
  sad('우울', '😢', Color(0xFF4F83CC)),
  angry('화남', '😠', Color(0xFFD95C5C));

  const DiaryMood(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.keywords,
    required this.satisfaction,
    required this.summary,
    this.isSample = false,
  });

  final String id;
  final DateTime date;
  final DiaryMood mood;
  final List<String> keywords;
  final int satisfaction;
  final String summary;
  final bool isSample;

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    DiaryMood? mood,
    List<String>? keywords,
    int? satisfaction,
    String? summary,
    bool? isSample,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      keywords: keywords ?? this.keywords,
      satisfaction: satisfaction ?? this.satisfaction,
      summary: summary ?? this.summary,
      isSample: isSample ?? this.isSample,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'keywords': keywords,
      'satisfaction': satisfaction,
      'summary': summary,
      'isSample': isSample,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: DiaryMood.values.byName(json['mood'] as String),
      keywords: List<String>.from(json['keywords'] as List),
      satisfaction: json['satisfaction'] as int,
      summary: json['summary'] as String,
      isSample: json['isSample'] as bool? ?? false,
    );
  }
}

String formatDiaryDate(DateTime date, {bool includeYear = true}) {
  final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
  final prefix = includeYear ? '${date.year}년 ' : '';
  return '$prefix${date.month}월 ${date.day}일 $weekday요일';
}

bool isSameDiaryDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
