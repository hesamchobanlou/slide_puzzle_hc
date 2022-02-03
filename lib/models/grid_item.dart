import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class GridItem {
  int row;
  int col;

  final int origRow;
  final int origCol;

  double dx;
  double dy;

  final double origDx;
  final double origDy;

  double? moveToDx;
  double? moveToDy;

  double height;
  double width;

  Image gridImage;

  GridItemType gridItemType;

  GridItem({
    required this.height,
    required this.width,
    required this.row,
    required this.col,
    required this.dx,
    required this.dy,
    this.moveToDx,
    this.moveToDy,
    required this.gridItemType,
    required this.gridImage,
  })  : origCol = col,
        origRow = row,
        origDx = dx,
        origDy = dy;

  void reset() {
    row = origRow;
    col = origCol;

    dx = origDx;
    dy = origDy;

    moveToDx = null;
    moveToDy = null;
  }

  void updatePosToMovementAndClear() {
    if (moveToDx != null && moveToDy != null) {
      dx = moveToDx!;
      dy = moveToDy!;

      moveToDx = null;
      moveToDy = null;
    }
  }

  bool inCorrectPosition() {
    if (row == origRow && col == origCol) {
      return true;
    }

    return false;
  }

  @override
  String toString() {
    return 'type:$gridItemType row:$row, col:$col origRow:$origRow origCol:$origCol dx:$dx dy:$dy origDx:$origDx origDy:$origDy moveToDx:$moveToDx moveToDy:$moveToDy';
  }
}
