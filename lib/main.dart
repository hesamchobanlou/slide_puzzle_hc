import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle_hc/widgets/animated_grid.dart';
import 'models/grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slide Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SlidePuzzle(),
    );
  }
}

class SlidePuzzle extends StatefulWidget {
  const SlidePuzzle({Key? key}) : super(key: key);
  @override
  State<SlidePuzzle> createState() => _SlidePuzzleState();
}

class _SlidePuzzleState extends State<SlidePuzzle> {
  Grid myGrid = Grid(
    rows: 4,
    columns: 4,
    gridItemDim: 100, // size x size
    gridItemPadding: 5,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: myGrid.initWithImage(
        puzzleImage: 'assets/images/puzzle_image.jpg',
        emptyBlockImage: 'assets/images/empty_block.png',
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: ChangeNotifierProvider(
              create: (context) => myGrid,
              child: const Center(
                child: AnimatedGrid(),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Loading...'),
            ),
          );
        }
      },
    );
  }
}
