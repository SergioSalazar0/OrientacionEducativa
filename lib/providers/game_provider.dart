import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/game.dart';
import '../data/models/player.dart';
import '../data/models/round.dart';
import '../data/models/team.dart';

const _uuid = Uuid();

final gameProvider =
    StateNotifierProvider<GameNotifier, Game>((ref) => GameNotifier());

class GameNotifier extends StateNotifier<Game> {
  GameNotifier() : super(const Game());

  void setTeams(Team team1, Team team2) {
    state = state.copyWith(
      team1: team1,
      team2: team2,
      rounds: [],
      currentRound: 1,
    );
  }

  void updatePlayerNickname(String teamId, String playerId, String nickname) {
    final team = teamId == state.team1?.id ? state.team1 : state.team2;
    if (team == null) return;

    final updatedPlayers = team.players.map((p) {
      if (p.id == playerId) return p.copyWith(nickname: nickname);
      return p;
    }).toList();

    final updatedTeam = team.copyWith(players: updatedPlayers);
    state = teamId == state.team1?.id
        ? state.copyWith(team1: updatedTeam)
        : state.copyWith(team2: updatedTeam);
  }

  void updatePlayerAvatar(String teamId, String playerId, int avatarIndex) {
    final team = teamId == state.team1?.id ? state.team1 : state.team2;
    if (team == null) return;

    final updatedPlayers = team.players.map((p) {
      if (p.id == playerId) return p.copyWith(avatarIndex: avatarIndex);
      return p;
    }).toList();

    final updatedTeam = team.copyWith(players: updatedPlayers);
    state = teamId == state.team1?.id
        ? state.copyWith(team1: updatedTeam)
        : state.copyWith(team2: updatedTeam);
  }

  void updatePlayerScoreForRound(
    String teamId,
    String playerId,
    int roundIndex,
    int score,
  ) {
    final team = teamId == state.team1?.id ? state.team1 : state.team2;
    if (team == null) return;

    final player = team.players.firstWhere((p) => p.id == playerId);
    final newScores = List<int>.from(player.scores);
    while (newScores.length <= roundIndex) {
      newScores.add(0);
    }
    newScores[roundIndex] = score;

    final updatedPlayers = team.players.map((p) {
      if (p.id == playerId) return p.copyWith(scores: newScores);
      return p;
    }).toList();

    final updatedTeam = team.copyWith(players: updatedPlayers);
    state = teamId == state.team1?.id
        ? state.copyWith(team1: updatedTeam)
        : state.copyWith(team2: updatedTeam);
  }

  void saveRoundAndStartNext(Map<String, int> roundScores) {
    var team1 = state.team1;
    var team2 = state.team2;
    if (team1 == null || team2 == null) return;

    final roundNumber = state.rounds.length + 1;
    final newRound = Round(roundNumber: roundNumber, scores: roundScores);

    for (final entry in roundScores.entries) {
      final playerId = entry.key;
      final score = entry.value;
      if (team1!.players.any((p) => p.id == playerId)) {
        final player = team1.players.firstWhere((p) => p.id == playerId);
        final newScores = [...player.scores, score];
        final updatedPlayers = team1.players.map((p) {
          if (p.id == playerId) return p.copyWith(scores: newScores);
          return p;
        }).toList();
        team1 = team1.copyWith(players: updatedPlayers);
      } else if (team2!.players.any((p) => p.id == playerId)) {
        final player = team2.players.firstWhere((p) => p.id == playerId);
        final newScores = [...player.scores, score];
        final updatedPlayers = team2.players.map((p) {
          if (p.id == playerId) return p.copyWith(scores: newScores);
          return p;
        }).toList();
        team2 = team2.copyWith(players: updatedPlayers);
      }
    }

    state = state.copyWith(
      team1: team1,
      team2: team2,
      rounds: [...state.rounds, newRound],
      currentRound: roundNumber + 1,
    );
  }

  void resetGame() {
    state = const Game();
  }

  Team? get winningTeam {
    final t1 = state.team1;
    final t2 = state.team2;
    if (t1 == null || t2 == null) return null;
    return t1.totalScore >= t2.totalScore ? t1 : t2;
  }
}

Team createEmptyTeam(String name, String displayName) {
  return Team(
    id: _uuid.v4(),
    name: name,
    displayName: displayName,
    players: List.generate(
      4,
      (i) => Player(
        id: _uuid.v4(),
        nickname: '',
        avatarIndex: -1,
      ),
    ),
  );
}
