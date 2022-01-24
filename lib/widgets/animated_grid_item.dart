import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle_hc/models/grid.dart';
import 'package:slide_puzzle_hc/models/grid_item.dart';

class AnimatedGridItem extends AnimatedWidget {
  final GridItem gridItem;

  const AnimatedGridItem({
    Key? key,
    required this.gridItem,
    required Animation<Offset> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<Offset>;

    print(
        'Animated Grid Item Type:${gridItem.type}, X:${gridItem.dx}, Y:${gridItem.dy}');

    return Transform.translate(
      offset: animation.value,
      child: GestureDetector(
        onTap: () {
          print(
              'tapped on Grid Item - X:${gridItem.dx} Y:${gridItem.dy} Type:${gridItem.type}');

          Provider.of<Grid>(context, listen: false).swapToEmptyTile(gridItem);
        },
        child: Container(
          child: SizedBox(
            child: Text(gridItem.type),
            width: gridItem.width,
            height: gridItem.height,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
