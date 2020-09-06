import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';



//this widget is for dsplying data of (acc or gyro) in a table
class ChartTracer extends StatelessWidget {
  const ChartTracer({
    Key key,
    @required  this.x,
   // @required this.x,
    //@required this.y,
   // @required this.z,
  }) :  super(key: key);

  //final int _counter;
  // final List<double> xValue = List();
  // final List<double> yValue = List();
  // final List<double> zValue = List();
  final double x;
  //final double y;
 // final double z;
  //List<double> traceDust = [];


  @override
  Widget build(BuildContext context) {
    List<double> traceDust = [];
    Oscilloscope oscilloscope = Oscilloscope(
      showYAxis: true,
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.white,
      dataSet: traceDust,
    );

    return Container(
      
    );
  }
}
