import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/avatar_urls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../data/models/player.dart';
import '../../data/models/team.dart';
import '../../providers/game_provider.dart';

class TeamRegistrationScreen extends ConsumerStatefulWidget {
  const TeamRegistrationScreen({super.key});

  @override
  ConsumerState<TeamRegistrationScreen> createState() =>
      _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends ConsumerState<TeamRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = ref.read(gameProvider);
      if (game.team1 == null || game.team2 == null) {
        ref.read(gameProvider.notifier).setTeams(
              createEmptyTeam('Equipo 01', 'Exploradores del Tiempo'),
              createEmptyTeam('Equipo 02', 'Guardianes de la Historia'),
            );
      }
    });
  }

  bool _canConfirm() {
    final game = ref.read(gameProvider);
    final t1 = game.team1;
    final t2 = game.team2;
    if (t1 == null || t2 == null) return false;
    final t1HasPlayer = t1.players.any((p) => p.nickname.trim().isNotEmpty);
    final t2HasPlayer = t2.players.any((p) => p.nickname.trim().isNotEmpty);
    return t1HasPlayer && t2HasPlayer;
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(gameProvider.notifier).resetGame();
            context.go(AppRouter.home);
          },
        ),
        title: const Text('Registro de Expedición'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
        ),
        child: CustomPaint(
          painter: _FieldNotePainter(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _AvatarLibrary(),
              const SizedBox(height: 24),
              _TeamSection(
                team: team1,
                otherTeam: team2,
                badge: 'Exploradores del Tiempo',
                icon: Icons.explore,
              ),
              const SizedBox(height: 24),
              _TeamSection(
                team: team2,
                otherTeam: team1,
                badge: 'Guardianes de la Historia',
                icon: Icons.map,
              ),
              const SizedBox(height: 100),
            ],
          ),
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
          color: AppColors.backgroundLight.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _canConfirm()
                  ? () => context.go(AppRouter.scoreboard)
                  : null,
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('CONFIRMAR EQUIPOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
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

class _AvatarLibrary extends StatelessWidget {
  const _AvatarLibrary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'BIBLIOTECA DE EXPLORADORES',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return _AvatarTile(url: AvatarUrls.urls[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.transparent,
            width: 2,
          ),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
      child: ClipOval(
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _TeamSection extends ConsumerWidget {
  const _TeamSection({
    required this.team,
    required this.otherTeam,
    required this.badge,
    required this.icon,
  });

  final Team team;
  final Team otherTeam;
  final String badge;
  final IconData icon;

  /// Índices de avatares ya seleccionados por otros jugadores (excluyendo al actual).
  Set<int> _takenAvatarIndicesExcluding(Player currentPlayer) {
    final taken = <int>{};
    for (final p in [...team.players, ...otherTeam.players]) {
      if (p.id != currentPlayer.id && p.avatarIndex >= 0) {
        taken.add(p.avatarIndex);
      }
    }
    return taken;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9DCCE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badge == 'Exploradores del Tiempo'
                  ? AppColors.primary
                  : const Color(0xFF231A0F),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team.name.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              Icon(icon, color: AppColors.primary.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(4, (i) {
                final player = team.players[i];
                return _PlayerRow(
                  key: ValueKey(player.id),
                  player: player,
                  placeholder: 'Apodo del Explorador ${i + 1}...',
                  avatarUrls: AvatarUrls.urls,
                  takenAvatarIndices: _takenAvatarIndicesExcluding(player),
                  onNicknameChanged: (v) => ref
                      .read(gameProvider.notifier)
                      .updatePlayerNickname(team.id, player.id, v),
                  onAvatarSelected: (idx) => ref
                      .read(gameProvider.notifier)
                      .updatePlayerAvatar(team.id, player.id, idx),
                );
              }),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatefulWidget {
  const _PlayerRow({
    super.key,
    required this.player,
    required this.placeholder,
    required this.avatarUrls,
    required this.takenAvatarIndices,
    required this.onNicknameChanged,
    required this.onAvatarSelected,
  });

  final Player player;
  final String placeholder;
  final List<String> avatarUrls;
  final Set<int> takenAvatarIndices;
  final void Function(String) onNicknameChanged;
  final void Function(int) onAvatarSelected;

  @override
  State<_PlayerRow> createState() => _PlayerRowState();
}

class _PlayerRowState extends State<_PlayerRow> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.player.nickname);
  }

  @override
  void didUpdateWidget(_PlayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.id != widget.player.id ||
        oldWidget.player.nickname != widget.player.nickname) {
      _nicknameController.text = widget.player.nickname;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona un explorador',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Los avatares ya elegidos no están disponibles',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final isTaken = widget.takenAvatarIndices.contains(index);
                final isSelected = widget.player.avatarIndex == index;
                return GestureDetector(
                  onTap: isTaken
                      ? null
                      : () {
                          widget.onAvatarSelected(index);
                          Navigator.pop(context);
                        },
                  child: Opacity(
                    opacity: isTaken ? 0.4 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isTaken
                                  ? Colors.grey.withValues(alpha: 0.5)
                                  : Colors.transparent,
                          width: 2,
                        ),
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              widget.avatarUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person, color: AppColors.primary),
                            ),
                          ),
                          if (isTaken)
                            Positioned.fill(
                              child: ClipOval(
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = widget.player.avatarIndex >= 0 &&
        widget.player.avatarIndex < widget.avatarUrls.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAvatarPickerSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasAvatar
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: hasAvatar ? 2 : 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                color: hasAvatar
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.05),
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.asset(
                        widget.avatarUrls[widget.player.avatarIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.add_a_photo,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _nicknameController,
              onChanged: widget.onNicknameChanged,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
