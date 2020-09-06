import 'package:flutter/material.dart';

class CurvedWidget extends StatelessWidget {
  final Widget child;
  final double curvedDistance;
  final double curvedHeight;

  // ignore: sort_constructors_first
  const CurvedWidget(
      {Key key, this.curvedDistance = 100, this.curvedHeight = 80, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedWidgetBackgroundClipper(
        curvedDistance: curvedDistance,
        curvedHeight: curvedHeight,
      ),
      child: child,
    );
  }
}

class CurvedWidgetBackgroundClipper extends CustomClipper<Path> {
  final double curvedDistance;
  final double curvedHeight;

  // ignore: sort_constructors_first
  CurvedWidgetBackgroundClipper({this.curvedDistance, this.curvedHeight});

  @override
  Path getClip(Size size) {
    var clippedPath = Path();
    clippedPath.lineTo(size.width, 0);
    clippedPath.lineTo(size.width, size.height - curvedDistance - curvedHeight);
    clippedPath.quadraticBezierTo(size.width, size.height - curvedHeight,
        size.width - curvedDistance, size.height - curvedHeight);
    clippedPath.lineTo(curvedDistance, size.height - curvedHeight);
    clippedPath.quadraticBezierTo(
        0, size.height - curvedHeight, 0, size.height);
    clippedPath.lineTo(0, 0);
    return clippedPath;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
