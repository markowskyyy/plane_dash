import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/presentation/providers/game_provider.dart';
import 'package:plane_dash/presentation/pages/widgets/game_field.dart';

class GamePage extends ConsumerWidget {
  final Difficulty? initialDifficulty;

  const GamePage({super.key, this.initialDifficulty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              // Автостарт игры при первой загрузке
              if (!gameState.isPlaying && !gameState.isGameOver) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.startGame(
                    difficulty: initialDifficulty ?? Difficulty.pilot,
                    screenWidth: screenSize.width,
                  );
                });
              }

              return Stack(
                children: [
                  // Игровое поле (CustomPaint)
                  GameField(screenSize: screenSize),

                  // --- Интерфейс: панели и кнопки ---
                  // Счёт (слева сверху)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _ScorePanel(score: gameState.score),
                  ),
                  // Звёзды (справа сверху)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _StarsPanel(stars: gameState.starsCollected),
                  ),
                  // Кнопка паузы (по центру сверху)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _PauseButton(
                        isPaused: gameState.isPaused,
                        onPressed: gameState.isPlaying
                            ? (gameState.isPaused
                            ? controller.resumeGame
                            : controller.pauseGame)
                            : null,
                      ),
                    ),
                  ),

                  if (gameState.isPaused)
                    _PauseOverlay(
                      onResume: controller.resumeGame,
                      onRestart: () => controller.restartGame(screenWidth: screenSize.width),
                    ),

                  // --- Оверлей окончания игры ---
                  if (gameState.isGameOver)
                    _GameOverOverlay(
                      score: gameState.score,
                      starsCollected: gameState.starsCollected,
                      onRestart: () => controller.restartGame(screenWidth: screenSize.width),
                    ),

                  // --- Индикатор загрузки ---
                  if (gameState.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // --- Сообщение об ошибке ---
                  if (gameState.error != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: _ErrorBanner(
                        error: gameState.error!,
                        onDismiss: controller.clearError,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ----------

class _ScorePanel extends StatelessWidget {
  final int score;
  const _ScorePanel({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Text('Очки: $score', style: AppTextStyles.score),
    );
  }
}

class _StarsPanel extends StatelessWidget {
  final int stars;
  const _StarsPanel({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.starYellow, size: 24),
          const SizedBox(width: 4),
          Text('x$stars', style: AppTextStyles.score.copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback? onPressed;
  const _PauseButton({required this.isPaused, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panelWhite,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: IconButton(
        icon: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          color: AppColors.darkBlueText,
        ),
        iconSize: 36,
        onPressed: onPressed,
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  const _PauseOverlay({required this.onResume, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ПАУЗА',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Продолжить', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onRestart,
              child: const Text('Начать заново', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int starsCollected;
  final VoidCallback onRestart;
  const _GameOverOverlay({
    required this.score,
    required this.starsCollected,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ИГРА ОКОНЧЕНА',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text('Счёт: $score', style: const TextStyle(fontSize: 24, color: Colors.white)),
            Text(
              'Звёзд: $starsCollected',
              style: const TextStyle(fontSize: 24, color: AppColors.starYellow),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Играть снова', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(error, style: const TextStyle(color: Colors.white))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}