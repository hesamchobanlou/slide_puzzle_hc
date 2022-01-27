import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:image/image.dart' as imglib;

import 'package:slide_puzzle_hc/models/grid_item.dart';
import 'package:slide_puzzle_hc/models/grid_item_type.dart';

class Grid extends ChangeNotifier {
  late List<GridItem> tiles;

  late int rows;
  late int columns;

  late double tileDim;
  late double tilePadding;

  late List<int> _puzzleImage;
  late Image _emptyBlockImage;

  Grid({
    required this.rows,
    required this.columns,
    required this.tileDim,
    required this.tilePadding,
  }) {
    tiles = [];
  }

  Future<bool> initWithImage(
      {required String puzzleImage, required String emptyBlockImage}) async {
    Uint8List imageByteData =
        (await rootBundle.load(puzzleImage)).buffer.asUint8List();
    _puzzleImage = imageByteData.toList();

    _emptyBlockImage = Image.memory(
        (await rootBundle.load(emptyBlockImage)).buffer.asUint8List());

    _generatePuzzleFromImages();

    return true;
  }

  void _generatePuzzleFromImages() {
    if (_puzzleImage != null) {
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
        outputImages.add(_emptyBlockImage);

        // load images into grid items
        _buildGridItems(outputImages);
      }
    }
  }

  void _buildGridItems(List<Image> images) {
    for (int i = 0; i < images.length; i++) {
      double rowPadding = 0;
      double colPadding = 0;

      int row = _calcRow(i);
      int col = _calcCol(i);

      if (row > 0) {
        rowPadding = tilePadding;
      }

      if (col > 0) {
        colPadding = tilePadding;
      }

      Offset offset = _calcOffset(
        row,
        col,
        tileDim,
        rowPadding,
        colPadding,
      );

      GridItemType gridItemType;
      if (i == (images.length - 1)) {
        gridItemType = GridItemType.emptyGridItem;
      } else {
        gridItemType = GridItemType.filledGridItem;
      }

      tiles.add(
        GridItem(
            height: tileDim,
            width: tileDim,
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
    return (rows * (tileDim + tilePadding));
  }

  double width() {
    return (columns * (tileDim + tilePadding));
  }

  void swapToEmptyTile(GridItem tile) {
    GridItem? emptyTile;

    if (tile.gridItemType == GridItemType.filledGridItem) {
      // find empty tile
      int emptyTileIdx = -1;

      for (var i = 0; i < tiles.length; i++) {
        if (tiles[i].gridItemType == GridItemType.emptyGridItem) {
          emptyTileIdx = i;

          break;
        }
      }

      if (emptyTileIdx == -1) {
        throw Exception();
      } else {
        GridItem emptyTile = tiles[emptyTileIdx];

        print(
            'swap x: ${tile.dx} y:${tile.dy} type:${tile.gridItemType} with x:${emptyTile.dx} y:${emptyTile.dy} type:${emptyTile.gridItemType}');

        double tempDx = emptyTile.dx;
        double tempDy = emptyTile.dy;

        emptyTile.dx = tile.dx;
        emptyTile.dy = tile.dy;

        tile.dx = tempDx;
        tile.dy = tempDy;
      }
    }

    notifyListeners();
  }
}
