import 'package:flutter/material.dart';

import 'package:slide_puzzle_hc/models/grid_item.dart';

class AnimatedGridItem extends AnimatedWidget {
  final GridItem gridItem;

  final VoidCallback onItemTapped;

  const AnimatedGridItem(
      {Key? key,
      required this.gridItem,
      required Animation<Offset> animation,
      required this.onItemTapped})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<Offset>;

    print(
        'Animated Grid Item Type:${gridItem.gridItemType}, X:${gridItem.dx}, Y:${gridItem.dy}');

    return Transform.translate(
      offset: animation.value,
      child: GestureDetector(
        onTap: () {
          print(
              'tapped on Grid Item - X:${gridItem.dx} Y:${gridItem.dy} Type:${gridItem.gridItemType}');

          onItemTapped();
        },
        child: SizedBox(
          width: gridItem.width,
          height: gridItem.height,
          child: Container(
            child: Image(image: gridItem.gridImage.image),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
