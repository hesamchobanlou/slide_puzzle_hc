import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:image/image.dart' as imglib;

import 'package:slide_puzzle_hc/models/grid_item.dart';
import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class Grid extends ChangeNotifier {
  late List<GridItem> gridItems;

  late int rows;
  late int columns;

  late double gridItemDim;
  late double gridItemPadding;

  late List<int> _puzzleImage;

  late Image _emptyGridItemImage;
  late int _emptyGridItemIdx;

  late int playerMoves;

  Grid({
    required this.rows,
    required this.columns,
    required this.gridItemDim,
    required this.gridItemPadding,
  }) {
    gridItems = [];

    playerMoves = 0;
  }

  Future<bool> initWithImage(
      {required String puzzleImage, required String emptyBlockImage}) async {
    Uint8List imageByteData =
        (await rootBundle.load(puzzleImage)).buffer.asUint8List();
    _puzzleImage = imageByteData.toList();

    _emptyGridItemImage = Image.memory(
        (await rootBundle.load(emptyBlockImage)).buffer.asUint8List());

    _generatePuzzleFromImages();

    return true;
  }

  void _generatePuzzleFromImages() {
    imglib.Image? image = imglib.decodeJpg(_puzzleImage);

    if (image != null) {
      int x = 0, y = 0;
      int cropWidth = ((image.width) / rows).round();
      int cropHeight = ((image.height) / rows).round();

      List<imglib.Image> parts = [];
      for (int i = 0; i < columns; i++) {
        for (int j = 0; j < rows; j++) {
          parts.add(imglib.copyCrop(image, x, y, cropWidth, cropHeight));
          x += cropWidth;
        }
        x = 0;
        y += cropHeight;
      }

      List<Image> outputImages = [];
      for (var img in parts) {
        outputImages
            .add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
      }

      // remove the very last image
      outputImages.removeLast();

      // add empty block in-place of removed image
      outputImages.add(_emptyGridItemImage);

      _emptyGridItemIdx = outputImages.length - 1;

      // load images into grid items
      _buildGridItems(outputImages);
    }
  }

  void _buildGridItems(List<Image> images) {
    for (int i = 0; i < images.length; i++) {
      int row = _calcRow(i);
      int col = _calcCol(i);

      Offset offset = _calcOffset(row, col, gridItemDim);

      GridItemType gridItemType;
      if (i == (images.length - 1)) {
        gridItemType = GridItemType.emptyGridItem;
      } else {
        gridItemType = GridItemType.filledGridItem;
      }

      gridItems.add(
        GridItem(
            row: row,
            col: col,
            height: gridItemDim,
            width: gridItemDim,
            dx: offset.dx,
            dy: offset.dy,
            gridItemType: gridItemType,
            gridImage: images[i]),
      );
    }
  }

  int _calcRow(int idx) {
    return ((idx) / columns).floor();
  }

  int _calcCol(int idx) {
    return idx % columns;
  }

  Offset _calcOffset(int row, int col, double dim) {
    // padding
    double rowPadding = 0;
    double colPadding = 0;

    if (row > 0) {
      rowPadding = gridItemPadding;
    }

    if (col > 0) {
      colPadding = gridItemPadding;
    }

    // col determines x axis
    double dx = (col * (dim + colPadding));

    // row determines y axis
    double dy = (row * (dim + rowPadding));

    return Offset(dx, dy);
  }

  bool _canMoveGridItem(GridItem gridItemToMove) {
    if (gridItemToMove.gridItemType == GridItemType.filledGridItem) {
      GridItem emptyGridItem = gridItems[_emptyGridItemIdx];

      if (gridItemToMove.col == emptyGridItem.col) {
        if ((gridItemToMove.row - 1 == emptyGridItem.row) ||
            gridItemToMove.row + 1 == emptyGridItem.row) {
          return true;
        }
      } else if (gridItemToMove.row == emptyGridItem.row) {
        if ((gridItemToMove.col - 1 == emptyGridItem.col) ||
            (gridItemToMove.col + 1 == emptyGridItem.col)) {
          return true;
        }
      }

      return false;
    }

    return false;
  }

  double height() {
    return (rows * (gridItemDim + gridItemPadding));
  }

  double width() {
    return (columns * (gridItemDim + gridItemPadding));
  }

  void resetGrid() {
    for (GridItem item in gridItems) {
      item.reset();
    }

    playerMoves = 0;
  }

  void shuffleGrid() {
    gridItems.shuffle();

    // re-calc position
    for (int i = 0; i < gridItems.length; i++) {
      int row = _calcRow(i);
      int col = _calcCol(i);

      Offset offset = _calcOffset(row, col, gridItemDim);

      gridItems[i].row = row;
      gridItems[i].col = col;

      gridItems[i].moveToDx = offset.dx;
      gridItems[i].moveToDy = offset.dy;

      // update empty grid item index
      if (gridItems[i].gridItemType == GridItemType.emptyGridItem) {
        _emptyGridItemIdx = i;
      }
    }
  }

  void swapWithGridItem(GridItem gridItem) {
    if (_canMoveGridItem(gridItem)) {
      GridItem emptyGridItem = gridItems[_emptyGridItemIdx];

      print('Swap - ' +
          gridItem.toString() +
          ' - with - ' +
          emptyGridItem.toString());

      double tempDx = emptyGridItem.dx;
      double tempDy = emptyGridItem.dy;

      int tempRow = emptyGridItem.row;
      int tempCol = emptyGridItem.col;

      emptyGridItem.moveToDx = gridItem.dx;
      emptyGridItem.moveToDy = gridItem.dy;

      emptyGridItem.row = gridItem.row;
      emptyGridItem.col = gridItem.col;

      gridItem.moveToDx = tempDx;
      gridItem.moveToDy = tempDy;

      gridItem.row = tempRow;
      gridItem.col = tempCol;

      playerMoves += 1;
    }

    notifyListeners();
  }

  void clearGridMovements(GridItem gridItem) {
    GridItem emptyGridItem = gridItems[_emptyGridItemIdx];

    gridItem.updatePosToMovementAndClear();

    // empty grid item is never clicked, so we do this here
    emptyGridItem.updatePosToMovementAndClear();

    print('Updated GridItem - ' + emptyGridItem.toString());
  }

  void clearAllGridMovements() {
    for (GridItem item in gridItems) {
      clearGridMovements(item);
    }
  }
}
