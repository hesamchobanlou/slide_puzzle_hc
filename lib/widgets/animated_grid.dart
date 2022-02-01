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

  late bool _gameStarted;

  late String _gameButtonText;

  @override
  void initState() {
    _gameStarted = false;

    _gameButtonText = 'Start Game';

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
        return Container(
          padding: const EdgeInsets.only(top: 35),
          child: Column(
            children: [
              // TODO: timer
              Text(
                'Timer: 00:00   |   Moves: ${grid.playerMoves}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: grid.height(),
                width: grid.width(),
                child: Stack(
                  children: _buildGridItems(
                      grid.gridItems, grid.height(), grid.width()),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  primary: Colors.green.shade400,
                ),
                onPressed: () {
                  setState(
                    () {
                      if (_gameStarted) {
                        _gameStarted = false;

                        _gameButtonText = 'Start Game';

                        Provider.of<Grid>(context, listen: false).resetGrid();
                      } else {
                        _gameStarted = true;

                        _gameButtonText = 'Reset Game';

                        Provider.of<Grid>(context, listen: false).shuffleGrid();

                        _controller.forward().whenCompleteOrCancel(() {
                          Provider.of<Grid>(context, listen: false)
                              .clearAllGridMovements();

                          _controller.stop(canceled: false);
                          _controller.value = 0;
                        });
                      }
                    },
                  );
                },
                child: Text(
                  _gameButtonText,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
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
        print('onItemTapped - ' + gridItem.toString());

        if (!_controller.isAnimating &&
            _gameStarted &&
            gridItem.gridItemType != GridItemType.emptyGridItem) {
          Provider.of<Grid>(context, listen: false).swapWithGridItem(gridItem);

          _controller.forward().whenCompleteOrCancel(() {
            Provider.of<Grid>(context, listen: false)
                .clearGridMovements(gridItem);

            _controller.stop(canceled: false);
            _controller.value = 0;
          });
        }
      },
    );
  }
}
