import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_dash/data/consts/design.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.skyGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(top: 20, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flight,
                    size: 60,
                    color: AppColors.accentRed,
                  ),
                ),
                const Text(
                  'Plane Dash',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Версия 1.0.0',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 32),

                // Карточка с описанием
                _buildInfoCard(),
                const SizedBox(height: 24),

                // Карточка "Как играть"
                _buildHowToPlayCard(),
                const SizedBox(height: 24),

                // Карточка "О разработчике"
                _buildDeveloperCard(),
                const SizedBox(height: 32),

                // Копирайт
                Text(
                  '© ${DateTime.now().year} Plane Dash Team',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Все права защищены',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.accentRed),
              const SizedBox(width: 8),
              Text(
                'О приложении',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Plane Dash — это бесконечный раннер с видом сверху, '
                'вдохновлённый классическими аркадными леталками. '
                'Управляйте истребителем, уклоняйтесь от препятствий, '
                'собирайте звёзды и ставьте новые рекорды!',
            style: AppTextStyles.body,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gamepad, color: AppColors.accentRed),
              const SizedBox(width: 8),
              Text(
                'Как играть',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHowToItem(
            icon: Icons.swipe,
            text: 'Свайпайте влево‑вправо, чтобы управлять самолётом',
          ),
          _buildHowToItem(
            icon: Icons.star,
            text: 'Собирайте золотые звёзды — каждая даёт 10 очков',
            iconColor: AppColors.starYellow,
          ),
          _buildHowToItem(
            icon: Icons.warning,
            text: 'Избегайте тёмных препятствий — столкновение заканчивает игру',
            iconColor: AppColors.obstacleDark,
          ),
          _buildHowToItem(
            icon: Icons.pause,
            text: 'Пауза в любой момент — кнопка в центре сверху',
          ),
          const SizedBox(height: 8),
          const Text(
            'Чем дольше летите, тем выше счёт. Удачи в небе!',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToItem({
    required IconData icon,
    required String text,
    Color iconColor = AppColors.accentRed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.app_blocking, color: AppColors.accentRed),
              const SizedBox(width: 8),
              Text(
                'Разработчик',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Plane Dash for MST',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Сделано с для всех любителей аркадных раннеров',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}