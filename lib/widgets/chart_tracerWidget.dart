import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';



//this widget is for dsplying data of (acc or gyro) in a chart
class ChartTracer extends StatelessWidget {
  const ChartTracer({
    Key key,
    @required  this.x,
  }) :  super(key: key);

  final double x;
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
