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

    double _opacity = 1.0;

    print('Animated GridItem - ' + gridItem.toString());

    return Transform.translate(
      offset: animation.value,
      child: GestureDetector(
        onTap: () {
          print('Tapped on GridItem - ' + gridItem.toString());

          onItemTapped();
        },
        child: SizedBox(
          width: gridItem.width,
          height: gridItem.height,
          child: Opacity(
            opacity: _opacity,
            child: Container(
              child: Image(
                image: gridItem.gridImage.image,
                fit: BoxFit.fill,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  width: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
