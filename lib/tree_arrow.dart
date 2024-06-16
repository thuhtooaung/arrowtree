import 'dart:math';

import 'package:flutter/material.dart';

class TreeArrow extends StatelessWidget {
  const TreeArrow(
      {super.key,
      required this.width,
      required this.height,
      required this.strokeWidth,
      required this.numberOfArrowHeads,
      this.color = Colors.black,
      this.arrowGaps = const [],
      this.tailGapFromStart = 0.0,
      this.tailPosition = TailPosition.center,
      this.hideStartArrow = false,
      this.hideEndArrow = false,
      this.hideArrowTail = false});

  final Color color;
  final double width;
  final double height;
  final double strokeWidth;
  final int numberOfArrowHeads;
  final List<double> arrowGaps;
  final double tailGapFromStart;
  final TailPosition tailPosition;
  final bool hideStartArrow;
  final bool hideEndArrow;
  final bool hideArrowTail;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: ArrowPainter(
          strokeWidth: strokeWidth,
          strokeColor: color,
          numOfHeads: numberOfArrowHeads,
          tailPosition: tailPosition,
          arrowGaps: arrowGaps,
          tailGap: tailGapFromStart,
          hideStartArrow: hideStartArrow,
          hideEndArrow: hideEndArrow,
          hideTail: hideArrowTail),
    );
  }
}

class ArrowPainter extends CustomPainter {
  ArrowPainter(
      {Key? key,
      required this.strokeWidth,
      required this.strokeColor,
      required this.numOfHeads,
      required this.tailPosition,
      required this.arrowGaps,
      required this.tailGap,
      required this.hideStartArrow,
      required this.hideEndArrow,
      required this.hideTail});

  final double strokeWidth;
  final Color strokeColor;
  final int numOfHeads;
  final TailPosition? tailPosition;
  final List<double> arrowGaps;
  final double tailGap;
  final bool hideStartArrow;
  final bool hideEndArrow;
  final bool hideTail;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth;

    drawTreeArrow(canvas, size, paint, numOfHeads);
  }

  void drawTreeArrow(Canvas canvas, Size size, Paint paint, int heads) {
    double xFactor = 1 / (2 * heads);
    Offset connectorStartOffset =
        Offset((size.width * xFactor) - (strokeWidth * 0.5), size.height * 0.5);
    Offset connectorEndOffset = Offset(size.width * xFactor, size.height * 0.5);
    var gapIndex = 0;
    for (var i = 1; i < heads * 2; i += 2) {
      // Central Placement
      double arrowGap = size.width * (xFactor * i);
      if (arrowGaps.isNotEmpty) {
        arrowGap = arrowGaps[gapIndex];
        if (gapIndex == 0) {
          connectorStartOffset =
              Offset(arrowGap - (strokeWidth * 0.5), size.height * 0.5);
        }
      }
      if (i + 1 == heads * 2) {
        connectorEndOffset = Offset(arrowGap + (strokeWidth * 0.5), size.height * 0.5);
      }

      if (hideStartArrow && i == 1) {
      } else if (hideEndArrow && (i + 1 == heads * 2)) {
      } else {
        // Drawing Arrow Tail
        Offset tailStartOffset =
            Offset(arrowGap, (size.height - (strokeWidth * 2)));
        Offset tailEndOffset =
            Offset(arrowGap, (size.height * 0.5) - (strokeWidth * 0.5));
        canvas.drawLine(tailStartOffset, tailEndOffset, paint);

        // Drawing Arrow Head
        Path headPath = Path();
        headPath.moveTo(arrowGap, size.height);
        headPath.lineTo(
            arrowGap - (strokeWidth * 2), (size.height - (strokeWidth * 2)));
        headPath.lineTo(
            arrowGap + (strokeWidth * 2), (size.height - (strokeWidth * 2)));
        headPath.close();
        canvas.drawPath(headPath, paint);
      }

      gapIndex += 1;
    }
    canvas.drawLine(connectorStartOffset, connectorEndOffset, paint);

    if (!hideTail) {
      // Drawing Input (Connector's tail)
      double connectorTailOffsetX = size.width * 0.5;
      if (arrowGaps.isNotEmpty) {
        connectorTailOffsetX = arrowGaps.reduce((a, b) => max(a, b)) / 2;
      }
      if (tailPosition == TailPosition.start) {
        connectorTailOffsetX = connectorStartOffset.dx + (strokeWidth * 0.5);
      } else if (tailPosition == TailPosition.end) {
        connectorTailOffsetX = connectorEndOffset.dx - (strokeWidth * 0.5);
      }
      if (tailGap > 0.0) {
        connectorTailOffsetX = tailGap;
      }
      Offset connectorTailStartOffset = Offset(
          connectorTailOffsetX, (size.height * 0.5) - (strokeWidth * 0.5));
      Offset connectorTailEndOffset = Offset(connectorTailOffsetX, 0);
      canvas.drawLine(connectorTailStartOffset, connectorTailEndOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

enum TailPosition { start, center, end }
