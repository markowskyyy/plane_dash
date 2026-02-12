import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/domain/enums/difficulty.dart';
import 'package:plane_dash/presentation/providers/training_provider.dart';

class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final controller = ref.read(trainingProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: trainingState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Испытай себя',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 16),
                _buildDifficultyCards(
                  context,
                  trainingState,
                  controller,
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(trainingState, controller),
                const SizedBox(height: 24),
                _buildStartButton(context, trainingState, controller),
                if (trainingState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _ErrorBanner(
                      error: trainingState.error!,
                      onDismiss: controller.clearError,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCards(
      BuildContext context,
      TrainingState state,
      TrainingController controller,
      ) {
    return Column(
      children: [
        _DifficultyCard(
          difficulty: Difficulty.novice,
          bestScore: state.bestScoreNovice,
          isSelected: state.selectedDifficulty == Difficulty.novice,
          onTap: () => controller.selectDifficulty(Difficulty.novice),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          difficulty: Difficulty.pilot,
          bestScore: state.bestScorePilot,
          isSelected: state.selectedDifficulty == Difficulty.pilot,
          onTap: () => controller.selectDifficulty(Difficulty.pilot),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          difficulty: Difficulty.ace,
          bestScore: state.bestScoreAce,
          isSelected: state.selectedDifficulty == Difficulty.ace,
          onTap: () => controller.selectDifficulty(Difficulty.ace),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
      TrainingState state,
      TrainingController controller,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Звук'),
            value: state.soundEnabled,
            onChanged: controller.toggleSound,
            activeColor: AppColors.accentRed,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Вибрация'),
            value: state.vibrationEnabled,
            onChanged: controller.toggleVibration,
            activeColor: AppColors.accentRed,
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: const Text('Чувствительность управления'),
            contentPadding: EdgeInsets.zero,
            subtitle: Slider(
              value: state.sensitivity,
              onChanged: controller.updateSensitivity,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(state.sensitivity * 100).round()}%',
              activeColor: AppColors.accentRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(
      BuildContext context,
      TrainingState state,
      TrainingController controller,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.selectedDifficulty != null
            ? () {
          // Переход на GamePage с выбранной сложностью
          context.go('/game?difficulty=${state.selectedDifficulty!.index}');
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: const Text(
          'НАЧАТЬ ТРЕНИРОВКУ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final int bestScore;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.bestScore,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panelWhite,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.accentRed, width: 3)
              : null,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Иконка сложности
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildIcon(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Лучший счёт: $bestScore',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isSelected ? AppColors.accentRed : AppColors.darkBlueText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (difficulty) {
      case Difficulty.novice:
        return const Icon(Icons.slow_motion_video, color: AppColors.accentRed);
      case Difficulty.pilot:
        return const Icon(Icons.flight, color: AppColors.accentRed);
      case Difficulty.ace:
        return const Icon(Icons.flash_on, color: AppColors.accentRed);
    }
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
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}