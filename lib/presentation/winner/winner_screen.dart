import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/avatar_urls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../data/models/player.dart';
import '../../data/models/team.dart';
import '../../providers/game_provider.dart';

class WinnerScreen extends ConsumerStatefulWidget {
  const WinnerScreen({super.key});

  @override
  ConsumerState<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends ConsumerState<WinnerScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bannerController;
  late Animation<double> _bannerScale;
  late Animation<double> _contentFade;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bannerScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.elasticOut),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bannerController,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );
    _bannerController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _shareWinner() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final xFile = XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'rastro_x_winner.png',
        );
        await Share.shareXFiles([
          xFile,
        ], text: '¡Somos los campeones de Rastro X!');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameProvider);
    final winningTeam =
        ref.read(gameProvider.notifier).winningTeam ?? _placeholderTeam();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'RASTRO X',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _bannerScale,
                          child: _VictoryBanner(),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CAMPEONES DE LA EXPEDICIÓN',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                winningTeam.displayName.isNotEmpty
                                    ? winningTeam.displayName.toUpperCase()
                                    : winningTeam.name.toUpperCase(),
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¡Felicidades! Han reescrito la historia con sus hallazgos.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              _WinningTeamPlayers(winningTeam: winningTeam),
                              const SizedBox(height: 24),
                              _StatsGrid(winningTeam: winningTeam),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Presume tu victoria',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ShareButton(
                    label: 'Compartir',
                    color: AppColors.primary,
                    icon: Icons.share,
                    onPressed: _shareWinner,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                AppColors.primary,
                Color(0xFFFFD700),
                Color(0xFFFFA500),
                Color(0xFFE8D5B7),
              ],
              shouldLoop: false,
            ),
          ),
        ],
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
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(gameProvider.notifier).resetGame();
                context.go(AppRouter.home);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('REINICIAR JUEGO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Team _placeholderTeam() {
    return Team(
      id: '',
      name: 'Equipo Ganador',
      displayName: 'Los Exploradores',
      players: [],
    );
  }
}

class _VictoryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 4,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          AppAssetUrls.victoryBanner,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.emoji_events, size: 80, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatarName extends StatelessWidget {
  const _PlayerAvatarName({
    required this.player,
    required this.index,
  });

  final Player player;
  final int index;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = player.avatarIndex >= 0 &&
        player.avatarIndex < AvatarUrls.urls.length;
    final displayName = player.nickname.trim().isNotEmpty
        ? player.nickname
        : 'Explorador ${index + 1}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasAvatar
                ? Image.asset(
                    AvatarUrls.urls[player.avatarIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _WinningTeamPlayers extends StatelessWidget {
  const _WinningTeamPlayers({required this.winningTeam});

  final Team winningTeam;

  @override
  Widget build(BuildContext context) {
    final players = winningTeam.players;
    if (players.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'EXPEDICIÓN GANADORA',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < players.length; i++)
                _PlayerAvatarName(
                  player: players[i],
                  index: i,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.winningTeam});

  final Team winningTeam;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: AppColors.primary, size: 40),
          const SizedBox(height: 8),
          Text(
            'PUNTOS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '${winningTeam.totalScore}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.label,
    required this.onPressed,
    required this.color,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
