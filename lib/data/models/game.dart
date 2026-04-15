import 'package:flutter/foundation.dart';

import 'round.dart';
import 'team.dart';

@immutable
class Game {
  const Game({
    this.team1,
    this.team2,
    this.rounds = const [],
    this.currentRound = 1,
  });

  final Team? team1;
  final Team? team2;
  final List<Round> rounds;
  final int currentRound;

  int get totalRounds => rounds.length;

  Game copyWith({
    Team? team1,
    Team? team2,
    List<Round>? rounds,
    int? currentRound,
  }) {
    return Game(
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      rounds: rounds ?? this.rounds,
      currentRound: currentRound ?? this.currentRound,
    );
  }
}
