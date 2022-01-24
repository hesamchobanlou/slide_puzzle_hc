import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item.dart';

class Grid extends ChangeNotifier {
  late List<GridItem> tiles;

  late int rows;
  late int columns;

  late double tileDim;
  late double tilePadding;

  double _xPaddingAdded = 0;
  double _yPaddingAdded = 0;

  Grid({
    required this.rows,
    required this.columns,
    required this.tileDim,
    required this.tilePadding,
  }) {
    tiles = [];

    // _generateTestPuzzle();
    _generateTestPuzzleWithRowCol(4);
  }

  void _generateTestPuzzleWithRowCol(int size) {
    for (var i = 0; i < size; i++) {
      double rowPadding = 0;
      double colPadding = 0;

      int row = _calcRow(i);
      int col = _calcCol(i);

      if (row > 0) {
        rowPadding = tilePadding;

        _yPaddingAdded += tilePadding;
      }

      if (col > 0) {
        colPadding = tilePadding;

        _xPaddingAdded = tilePadding;
      }

      Offset offset = _calcOffset(
        row,
        col,
        tileDim,
        rowPadding,
        colPadding,
      );

      // TODO: remove this later
      String type;
      if (i == 1) {
        type = 'EMPTY';
      } else {
        type = 'NON-EMPTY';
      }

      tiles.add(
        GridItem(
          height: tileDim,
          width: tileDim,
          dx: offset.dx,
          dy: offset.dy,
          type: type,
        ),
      );
    }
  }

  void _generateTestPuzzle() {
    tiles.add(GridItem(
        height: tileDim,
        width: tileDim,
        dx: 0,
        dy: 0,
        type: 'NON-EMPTY')); // top-left
    tiles.add(GridItem(
        height: tileDim,
        width: tileDim,
        dx: 50,
        dy: 0,
        type: 'EMPTY')); // top-right
    tiles.add(GridItem(
        height: tileDim,
        width: tileDim,
        dx: 0,
        dy: 50,
        type: 'NON-EMPTY')); // bottom-left
    tiles.add(GridItem(
        height: tileDim,
        width: tileDim,
        dx: 50,
        dy: 50,
        type: 'NON-EMPTY')); // botton-right
  }

  int _calcRow(int idx) {
    return ((idx) / columns).floor();
  }

  int _calcCol(int idx) {
    return idx % columns;
  }

  Offset _calcOffset(int row, int col, double dim,
      [double rowPadding = 0, double colPadding = 0]) {
    // col determines x axis
    double dx = (col * dim) + colPadding;

    // row determines y axis
    double dy = (row * dim) + rowPadding;

    return Offset(dx, dy);
  }

  double height() {
    // return (rows * tileDim);
    return (rows * tileDim) + _yPaddingAdded; // TODO: fix this
  }

  double width() {
    // return (columns * tileDim);
    return (columns * tileDim) + _xPaddingAdded; // TODO: fix this
  }

  void swapToEmptyTile(GridItem tile) {
    GridItem? emptyTile;

    if (tile.type == 'NON-EMPTY') {
      // find empty tile
      int emptyTileIdx = -1;

      for (var i = 0; i < tiles.length; i++) {
        if (tiles[i].type == 'EMPTY') {
          emptyTileIdx = i;

          break;
        }
      }

      if (emptyTileIdx == -1) {
        throw Exception();
      } else {
        GridItem emptyTile = tiles[emptyTileIdx];

        print(
            'swap x: ${tile.dx} y:${tile.dy} type:${tile.type} with x:${emptyTile.dx} y:${emptyTile.dy} type:${emptyTile.type}');

        var tempDx = emptyTile.dx;
        var tempDy = emptyTile.dy;

        emptyTile.dx = tile.dx;
        emptyTile.dy = tile.dy;

        tile.dx = tempDx;
        tile.dy = tempDy;
      }
    }

    notifyListeners();
  }
}
