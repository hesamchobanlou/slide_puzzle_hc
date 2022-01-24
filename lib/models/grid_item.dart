class GridItem {
  double dx;
  double dy;

  double height;
  double width;

  String type;

  GridItem({
    required this.height,
    required this.width,
    required this.dx,
    required this.dy,
    required this.type,
  });

  void setX(double dx) => {this.dx = dx};
  void setY(double dy) => {this.dy = dy};
}
