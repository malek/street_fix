import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';

class RecordShow extends StatefulWidget {
  @override
  _RecordShowState createState() => _RecordShowState();
}

class _RecordShowState extends State<RecordShow> {
  String recordresult = '';
  String buttonText = 'record';
  double x=0, y=0, z=0;
  bool visble = false;
  List axX, axY, axZ;

  final timeControler = new TextEditingController();
  //column for x y z
  Column results = new Column();
  int _counter;
  Timer _timer;

  //-------------------Functions

  //hide/show table block
  void toggleTable() {
     setState(() {
        visble = !visble;
      });
  }
 //to catch up the sensor data
  startAccelerometer() {
    print('startAccelerometer print');
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
        axX.add(x);
        axY.add(y);
        axZ.add(z);
      });
    }); //get the sensor data and set then to the data types
  }
  //some function to add once timer finish
  void onEndClallback() {
    print('on end print');
    // (_counter > 0) ? Text('') : Text('Done');
    Text('Done');
  }

  //timer from N second to zero
  void startCountDown(//counter, onEndcallBack
      ) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        print('tiiimergh  $_counter');
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
          onEndClallback();
        }
      });
    });
  }

  // show acc table
  showTableAcc() {
    print('show table');
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Recording starts:",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
          ),
        ),
        Text('$_counter'),
        Table(
          border: TableBorder.all(
              width: 2.0, color: Colors.blueAccent, style: BorderStyle.solid),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "X Asis : ",
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
                    "Y Asis : ",
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
                    "Z Asis : ",
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

 

  //Game started
  startRecording() {
    print('start recording print');
    startCountDown();
    startAccelerometer();
    toggleTable();
    showTableAcc();
  }

  //Game finished
  stopRecording() {
    toggleTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Street Fix'),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Reocord for(s): '),
                  ),
                  Container(
                    width: 100.0,
                    child: TextField(
                      controller: timeControler,
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 5.0),
                          )),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                    ),
                  ),
                ],
              ),
            ),
            RaisedButton(
                child: Text('Set Timer'),
                onPressed: () {
                  setState(() {
                    _counter = int.parse(timeControler
                        .text); //to convert the text input to int -time-
                  });
                  startRecording();

                  print('this isisisi $_counter');
                  //onclickStart = Container(
                  //child:                   );
                }),
            Visibility(
              child: showTableAcc(),
              visible: visble,
            ),
          ]),
        ));
  }
}
