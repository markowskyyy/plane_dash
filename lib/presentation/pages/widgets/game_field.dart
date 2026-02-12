import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/presentation/pages/widgets/game_painter.dart';
import 'package:plane_dash/presentation/providers/game_provider.dart';
import 'dart:ui' as ui;

class GameField extends ConsumerWidget {
  final Size screenSize;

  const GameField({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    final planeImageAsync = ref.watch(planeImageProvider);
    final ui.Image? planeImage = planeImageAsync.when(
      data: (image) => image,
      error: (Object error, StackTrace stackTrace) {  },
      loading: () {  },
    );

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -5) {
          controller.movePlaneLeft(screenSize.width);
        } else if (details.delta.dx > 5) {
          controller.movePlaneRight(screenSize.width);
        }
      },
      onTapDown: (details) {
        final tapX = details.localPosition.dx;
        if (tapX < screenSize.width / 2) {
          controller.movePlaneLeft(screenSize.width);
        } else {
          controller.movePlaneRight(screenSize.width);
        }
      },
      child: CustomPaint(
        size: screenSize,
        painter: GamePainter(
          planeX: gameState.planeX,
          planeImage: planeImage,
          stars: gameState.stars,
          obstacles: gameState.obstacles,
          screenSize: screenSize,

        ),
      )
    );
  }
}