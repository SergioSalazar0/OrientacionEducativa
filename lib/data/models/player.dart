import 'package:flutter/foundation.dart';

@immutable
class Player {
  const Player({
    required this.id,
    required this.nickname,
    this.avatarIndex = 0,
    this.scores = const [],
  });

  final String id;
  final String nickname;
  final int avatarIndex;
  final List<int> scores;

  Player copyWith({
    String? id,
    String? nickname,
    int? avatarIndex,
    List<int>? scores,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      scores: scores ?? this.scores,
    );
  }

  int get totalScore => scores.fold(0, (a, b) => a + b);
}
