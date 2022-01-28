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

  Grid({
    required this.rows,
    required this.columns,
    required this.gridItemDim,
    required this.gridItemPadding,
  }) {
    gridItems = [];
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
      double rowPadding = 0;
      double colPadding = 0;

      int row = _calcRow(i);
      int col = _calcCol(i);

      if (row > 0) {
        rowPadding = gridItemPadding;
      }

      if (col > 0) {
        colPadding = gridItemPadding;
      }

      Offset offset = _calcOffset(
        row,
        col,
        gridItemDim,
        rowPadding,
        colPadding,
      );

      GridItemType gridItemType;
      if (i == (images.length - 1)) {
        gridItemType = GridItemType.emptyGridItem;
      } else {
        gridItemType = GridItemType.filledGridItem;
      }

      gridItems.add(
        GridItem(
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

  Offset _calcOffset(int row, int col, double dim,
      [double rowPadding = 0, double colPadding = 0]) {
    // col determines x axis
    double dx = (col * (dim + colPadding));

    // row determines y axis
    double dy = (row * (dim + rowPadding));

    return Offset(dx, dy);
  }

  double height() {
    return (rows * (gridItemDim + gridItemPadding));
  }

  double width() {
    return (columns * (gridItemDim + gridItemPadding));
  }

  void clearGridMovement(GridItem gridItem) {
    GridItem emptyGridItem = gridItems[_emptyGridItemIdx];

    gridItem.updatePosToMovementAndClear();

    // empty grid item is never clicked, so we do this here
    emptyGridItem.updatePosToMovementAndClear();

    print(
        'udpated grid item type:${emptyGridItem.gridItemType} dx:${emptyGridItem.dx} dy:${emptyGridItem.dy} moveToDx:${emptyGridItem.moveToDx} moveToDy:${emptyGridItem.moveToDy}');
  }

  void swapToEmptyTile(GridItem tile) {
    if (tile.gridItemType == GridItemType.filledGridItem) {
      GridItem emptyGridItem = gridItems[_emptyGridItemIdx];

      print(
          'swap x: ${tile.dx} y:${tile.dy} type:${tile.gridItemType} with x:${emptyGridItem.dx} y:${emptyGridItem.dy} type:${emptyGridItem.gridItemType}');

      double tempDx = emptyGridItem.dx;
      double tempDy = emptyGridItem.dy;

      emptyGridItem.moveToDx = tile.dx;
      emptyGridItem.moveToDy = tile.dy;

      tile.moveToDx = tempDx;
      tile.moveToDy = tempDy;
    }

    notifyListeners();
  }
}
