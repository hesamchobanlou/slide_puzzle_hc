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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Grid myGrid = Grid(
    rows: 5,
    columns: 5,
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
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: ChangeNotifierProvider(
              create: (context) => myGrid,
              child: const Center(
                child: AnimatedGrid(),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
