import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class GridItem {
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
}
