import 'package:flutter/material.dart';
//this widget is for dsplying data of (acc or gyro) in a table
class TableData extends StatelessWidget {
  const TableData({
    Key key,
    @required int counter,
    @required this.x,
    @required this.y,
    @required this.z,
  }) : _counter = counter, super(key: key);

  final int _counter;
  final double x;
  final double y;
  final double z;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Recording starts:",
            style: TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.w900),
          ),
        ),
        Text('$_counter'),
        Table(
          border: TableBorder.all(
              width: 2.0,
              color: Colors.blueAccent,
              style: BorderStyle.solid),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "X Axis : ",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      x.toStringAsFixed(
                          2), //trim the asis value to 2 digit after decimal point
                      style: TextStyle(fontSize: 20.0)),
                )
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Y Axis : ",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      y.toStringAsFixed(
                          2), //trim the asis value to 2 digit after decimal point
                      style: TextStyle(fontSize: 20.0)),
                )
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Z Axis : ",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      z.toStringAsFixed(
                          2), //trim the asis value to 2 digit after decimal point
                      style: TextStyle(fontSize: 20.0)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
