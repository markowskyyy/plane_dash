import 'package:flutter/material.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/presentation/providers/game_provider.dart';

class GamePainter extends CustomPainter {
  final GameState gameState;
  final Size screenSize;

  GamePainter({required this.gameState, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    _drawClouds(canvas);
    _drawStars(canvas);
    _drawObstacles(canvas);
    _drawPlane(canvas);
  }

  void _drawClouds(Canvas canvas) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = (DateTime.now().millisecondsSinceEpoch / 50 % 800).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(50 + i * 80, (offset + i * 100) % 800, 80, 30),
          const Radius.circular(20),
        ),
        cloudPaint,
      );
    }
  }

  void _drawStars(Canvas canvas) {
    final starPaint = Paint()..color = AppColors.starYellow;
    for (var star in gameState.stars) {
      canvas.drawCircle(Offset(star.x, star.y), 15, starPaint);
      // Блик
      canvas.drawCircle(
        Offset(star.x - 3, star.y - 3),
        5,
        Paint()..color = Colors.white.withOpacity(0.7),
      );
    }
  }

  void _drawObstacles(Canvas canvas) {
    final obstaclePaint = Paint()..color = AppColors.obstacleDark;
    for (var obs in gameState.obstacles) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(obs.x, obs.y, obs.width, obs.height),
          const Radius.circular(8),
        ),
        obstaclePaint,
      );
      // Тень
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(obs.x + 2, obs.y + 2, obs.width, obs.height),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.black.withOpacity(0.2),
      );
    }
  }

  void _drawPlane(Canvas canvas) {
    final planeX = gameState.planeX;
    const planeY = 600; // фиксированная высота самолёта

    // Корпус (с размытием для эффекта скорости)
    final planePaint = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(planeX - 25, planeY - 20, 50, 40),
        const Radius.circular(12),
      ),
      planePaint,
    );

    // Крылья
    canvas.drawRect(
      Rect.fromLTWH(planeX - 35, planeY - 5, 70, 10),
      Paint()..color = AppColors.accentRed.withOpacity(0.8),
    );

    // Хвост
    canvas.drawPath(
      Path()
        ..moveTo(planeX - 15, planeY - 20)
        ..lineTo(planeX - 25, planeY - 40)
        ..lineTo(planeX - 5, planeY - 30)
        ..close(),
      Paint()..color = AppColors.accentRed,
    );

    // Кабина
    canvas.drawCircle(
      Offset(planeX + 10, planeY - 15),
      8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(planeX + 12, planeY - 17),
      4,
      Paint()..color = Colors.blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}