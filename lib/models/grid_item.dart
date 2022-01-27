import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class GridItem {
  double dx;
  double dy;

  double height;
  double width;

  Image gridImage;

  GridItemType gridItemType;

  GridItem(
      {required this.height,
      required this.width,
      required this.dx,
      required this.dy,
      required this.gridItemType,
      required this.gridImage});

  void setX(double dx) => {this.dx = dx};
  void setY(double dy) => {this.dy = dy};
}
