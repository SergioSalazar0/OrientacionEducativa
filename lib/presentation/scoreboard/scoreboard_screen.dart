import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/avatar_urls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../data/models/player.dart';
import '../../data/models/team.dart';
import '../../providers/game_provider.dart';

class ScoreboardScreen extends ConsumerStatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  ConsumerState<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends ConsumerState<ScoreboardScreen> {
  Map<String, TextEditingController> _scoreControllers = {};
  Map<String, int> _currentRoundScores = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initScores(ref));
  }

  void _initScores(WidgetRef ref) {
    final game = ref.read(gameProvider);
    final t1 = game.team1;
    final t2 = game.team2;
    if (t1 == null || t2 == null) return;

    _scoreControllers = {};
    _currentRoundScores = {};
    for (final p in [...t1.players, ...t2.players]) {
      _scoreControllers[p.id] = TextEditingController(text: '0');
      _currentRoundScores[p.id] = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> _getCurrentRoundScores() {
    final result = <String, int>{};
    for (final entry in _scoreControllers.entries) {
      final val = int.tryParse(entry.value.text) ?? 0;
      result[entry.key] = val;
    }
    return result;
  }

  void _clearCurrentRoundInputs() {
    for (final c in _scoreControllers.values) {
      c.text = '0';
    }
    _currentRoundScores.clear();
    for (final id in _scoreControllers.keys) {
      _currentRoundScores[id] = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final team1 = game.team1;
    final team2 = game.team2;

    if (team1 == null || team2 == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_scoreControllers.isNotEmpty) {
      _initScores(ref);
    }

    final roundNumber = game.rounds.length + 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.teamRegistration),
        ),
        title: Column(
          children: [
            const Text('Scoreboard'),
            Text(
              'Ronda $roundNumber',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomPaint(
        painter: _AgedPaperPainter(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TeamTotalsHeader(team1: team1, team2: team2),
            const SizedBox(height: 24),
            _TeamScoresSection(
              team: team1,
              isLeading: team1.totalScore >= team2.totalScore,
              scoreControllers: _scoreControllers,
              onScoreChanged: (playerId, value) {},
            ),
            const SizedBox(height: 24),
            _TeamScoresSection(
              team: team2,
              isLeading: team2.totalScore >= team1.totalScore,
              scoreControllers: _scoreControllers,
              onScoreChanged: (playerId, value) {},
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border(
            top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(gameProvider.notifier)
                        .saveRoundAndStartNext(_getCurrentRoundScores());
                    _clearCurrentRoundInputs();
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Agregar Ronda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final scores = _getCurrentRoundScores();
                    final hasScores = scores.values.any((v) => v > 0);
                    if (hasScores) {
                      ref
                          .read(gameProvider.notifier)
                          .saveRoundAndStartNext(scores);
                    }
                    context.go(AppRouter.winner);
                  },
                  icon: const Icon(Icons.flag),
                  label: const Text('Finalizar Juego'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    for (var x = 0.0; x < size.width; x += 24) {
      for (var y = 0.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TeamTotalsHeader extends StatelessWidget {
  const _TeamTotalsHeader({
    required this.team1,
    required this.team2,
  });

  final Team team1;
  final Team team2;

  @override
  Widget build(BuildContext context) {
    final t1Leading = team1.totalScore >= team2.totalScore;
    final t2Leading = team2.totalScore >= team1.totalScore;

    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t1Leading
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: t1Leading
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Equipo 1',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t1Leading ? AppColors.primary : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${team1.totalScore}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: t1Leading
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t2Leading
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: t2Leading
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Equipo 2',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t2Leading ? AppColors.primary : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${team2.totalScore}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: t2Leading
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamScoresSection extends StatelessWidget {
  const _TeamScoresSection({
    required this.team,
    required this.isLeading,
    required this.scoreControllers,
    required this.onScoreChanged,
  });

  final Team team;
  final bool isLeading;
  final Map<String, TextEditingController> scoreControllers;
  final void Function(String playerId, int value) onScoreChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.groups,
              color: isLeading
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              team.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...team.players.map((player) => _PlayerScoreRow(
              player: player,
              controller: scoreControllers[player.id],
              onScoreChanged: (v) => onScoreChanged(player.id, v),
            )),
      ],
    );
  }
}

class _PlayerScoreRow extends StatelessWidget {
  const _PlayerScoreRow({
    required this.player,
    required this.controller,
    required this.onScoreChanged,
  });

  final Player player;
  final TextEditingController? controller;
  final void Function(int) onScoreChanged;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            _PlayerAvatar(player: player),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                player.nickname.isEmpty ? 'Jugador' : player.nickname,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final v = (int.tryParse(controller!.text) ?? 0) - 1;
                    final newVal = v.clamp(0, 999);
                    controller!.text = '$newVal';
                    onScoreChanged(newVal);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) {
                      onScoreChanged(int.tryParse(v) ?? 0);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final v = (int.tryParse(controller!.text) ?? 0) + 1;
                    final newVal = v.clamp(0, 999);
                    controller!.text = '$newVal';
                    onScoreChanged(newVal);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        player.avatarIndex >= 0 && player.avatarIndex < AvatarUrls.urls.length;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.2),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.asset(
                AvatarUrls.urls[player.avatarIndex],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    (player.nickname.isNotEmpty
                            ? player.nickname[0]
                            : '?')
                        .toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  (player.nickname.isNotEmpty ? player.nickname[0] : '?')
                      .toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
