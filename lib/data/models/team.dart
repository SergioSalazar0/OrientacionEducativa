import 'package:flutter/foundation.dart';

import 'player.dart';

@immutable
class Team {
  const Team({
    required this.id,
    required this.name,
    this.displayName = '',
    this.players = const [],
  });

  final String id;
  final String name;
  final String displayName;
  final List<Player> players;

  int get totalScore => players.fold(0, (sum, p) => sum + p.totalScore);

  Team copyWith({
    String? id,
    String? name,
    String? displayName,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      players: players ?? this.players,
    );
  }
}
