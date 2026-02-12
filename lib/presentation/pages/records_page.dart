import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/domain/entities/game_record.dart';
import 'package:plane_dash/presentation/providers/records_provider.dart';

class RecordsPage extends ConsumerWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsState = ref.watch(recordsProvider);
    final controller = ref.read(recordsProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.skyGradient),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: recordsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Лучшие результаты',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 24),
                _buildStats(recordsState),
                const SizedBox(height: 24),
                _buildResetButton(context, controller),
                if (recordsState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _ErrorBanner(
                      error: recordsState.error!,
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

  Widget _buildRecordsTable(List<GameRecord> records) {
    if (records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(),
        child: const Text(
          'Пока нет рекордов.\nСыграйте первый полёт!',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < records.length; i++) ...[
            if (i > 0) const Divider(),
            _buildRecordRow(i, records[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordRow(int index, GameRecord record) {
    String medal;
    Color medalColor;
    if (index == 0) {
      medal = '🥇';
      medalColor = const Color(0xFFFFD700);
    } else if (index == 1) {
      medal = '🥈';
      medalColor = const Color(0xFFC0C0C0);
    } else if (index == 2) {
      medal = '🥉';
      medalColor = const Color(0xFFCD7F32);
    } else {
      medal = '${index + 1}';
      medalColor = AppColors.darkBlueText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              medal,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: medalColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              record.playerName,
              style: AppTextStyles.body,
            ),
          ),
          Expanded(
            child: Text(
              '${record.score}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${record.date.day}.${record.date.month}',
            style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(RecordsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ваша статистика',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 16),
          _statRow('Всего собрано звёзд:', '${state.totalStars} ★'),
          _statRow('Всего полётов:', '${state.totalFlights}'),
          _statRow('Лучший результат:', '${state.bestScore} очков'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, RecordsController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showResetDialog(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Сбросить весь прогресс',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: AppColors.panelWhite,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, RecordsController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить прогресс'),
        content: const Text(
          'Все рекорды, звёзды и статистика будут удалены. Вы уверены?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              controller.resetProgress();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Сбросить',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
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