import 'package:flutter/foundation.dart';

@immutable
class Round {
  const Round({
    required this.roundNumber,
    this.scores = const {},
  });

  final int roundNumber;
  final Map<String, int> scores;

  Round copyWith({
    int? roundNumber,
    Map<String, int>? scores,
  }) {
    return Round(
      roundNumber: roundNumber ?? this.roundNumber,
      scores: scores ?? this.scores,
    );
  }
}
