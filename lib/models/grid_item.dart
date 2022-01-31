import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class GridItem {
  int row;
  int col;

  double dx;
  double dy;

  double? moveToDx;
  double? moveToDy;

  double height;
  double width;

  Image gridImage;

  GridItemType gridItemType;

  GridItem(
      {required this.height,
      required this.width,
      required this.row,
      required this.col,
      required this.dx,
      required this.dy,
      this.moveToDx,
      this.moveToDy,
      required this.gridItemType,
      required this.gridImage});

  void updatePosToMovementAndClear() {
    if (moveToDx != null && moveToDy != null) {
      dx = moveToDx!;
      dy = moveToDy!;

      moveToDx = null;
      moveToDy = null;
    }
  }

  @override
  String toString() {
    return 'type:$gridItemType row:$row, col:$col dx:$dx dy:$dy moveToDx:$moveToDx moveToDy:$moveToDy';
  }
}
