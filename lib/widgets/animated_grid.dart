import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle_hc/models/grid.dart';
import 'package:slide_puzzle_hc/models/grid_item.dart';
import 'package:slide_puzzle_hc/models/grid_item_type.dart';
import 'package:slide_puzzle_hc/widgets/animated_grid_item.dart';

class AnimatedGrid extends StatefulWidget {
  const AnimatedGrid({Key? key}) : super(key: key);

  @override
  _AnimatedGridState createState() => _AnimatedGridState();
}

class _AnimatedGridState extends State<AnimatedGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Grid>(
      builder: (context, grid, child) {
        return SizedBox(
          height: grid.height(),
          width: grid.width(),
          child: Stack(
            children:
                _buildGridItems(grid.gridItems, grid.height(), grid.width()),
          ),
        );
      },
    );
  }

  List<Widget> _buildGridItems(
      List<GridItem> gridItems, double gridHeight, double gridWidth) {
    List<Widget> builtGridItemWidget = [];
    for (var i = 0; i < gridItems.length; i++) {
      GridItem curGridItem = gridItems[i];

      builtGridItemWidget
          .add(_buildGridItem(curGridItem, gridHeight, gridWidth));
    }

    return builtGridItemWidget;
  }

  Widget _buildGridItem(
      GridItem gridItem, double gridHeight, double gridWidth) {
    Offset offset = Offset(gridItem.dx, gridItem.dy);

    // calculate begin and end offset?
    Offset beginOffset = offset;
    Offset endOffset = offset;

    if (gridItem.moveToDx != null && gridItem.moveToDy != null) {
      endOffset = Offset(gridItem.moveToDx!, gridItem.moveToDy!);
    }

    // offset tween
    _animation =
        Tween<Offset>(begin: beginOffset, end: endOffset).animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    return AnimatedGridItem(
      gridItem: gridItem,
      animation: _animation,
      onItemTapped: () {
        print('onItemTapped');

        if (!_controller.isAnimating &&
            gridItem.gridItemType != GridItemType.emptyGridItem) {
          Provider.of<Grid>(context, listen: false).swapToEmptyTile(gridItem);

          _controller.forward().whenCompleteOrCancel(() {
            Provider.of<Grid>(context, listen: false)
                .clearGridMovement(gridItem);

            _controller.stop(canceled: false);
            _controller.value = 0;
          });
        }
      },
    );
  }
}
