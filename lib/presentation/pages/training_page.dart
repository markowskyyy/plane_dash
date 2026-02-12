import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/presentation/providers/achievements_provider.dart';

class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);
    final controller = ref.read(achievementsProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => controller.loadAchievements(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  const Text(
                    'Мои достижения',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 24),

                  // Блок статистики
                  _buildStatsCard(state),
                  const SizedBox(height: 24),

                  // Список достижений
                  const Text(
                    'Прогресс',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementsList(state.achievements),

                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _ErrorBanner(
                        error: state.error!,
                        onDismiss: controller.clearError,
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

  Widget _buildStatsCard(AchievementsState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: const Icon(Icons.star, color: AppColors.starYellow, size: 32),
                label: 'Звёзды',
                value: '${state.totalStars}',
              ),
              _StatItem(
                icon: const Icon(Icons.flight, color: AppColors.accentRed, size: 32),
                label: 'Полёты',
                value: '${state.totalFlights}',
              ),
              _StatItem(
                icon: const Icon(Icons.emoji_events, color: AppColors.accentRed, size: 32),
                label: 'Рекорд',
                value: '${state.bestScore}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    return Column(
      children: achievements.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.panelWhite,
            borderRadius: BorderRadius.circular(16),
            border: achievement.isCompleted
                ? Border.all(color: AppColors.starYellow, width: 2)
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
              // Иконка
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: achievement.isCompleted
                      ? AppColors.starYellow.withOpacity(0.2)
                      : AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    achievement.iconAsset,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Прогресс-бар
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          achievement.isCompleted
                              ? AppColors.starYellow
                              : AppColors.accentRed,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Текст прогресса
                    Text(
                      '${achievement.current} / ${achievement.target}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Значок выполнено
              if (achievement.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.starYellow,
                    size: 28,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.score.copyWith(fontSize: 22),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
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