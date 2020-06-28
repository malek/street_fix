import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/widgets/tableData.dart';
import 'package:street_fix/functions/csvMaker.dart';

class RecordShow extends StatefulWidget {
  @override
  _RecordShowState createState() => _RecordShowState();
}

class _RecordShowState extends State<RecordShow> {
  //-----------Declarations--------------

  double x = 0, y = 0, z = 0; // for acc data
  bool visble =
      false; //for the visibility of the block(Acc table, countDown number)
  final timeControler = new TextEditingController(); //fot thr entred time

  Column results =
      new Column(); //column for x y z table * in the begining ykon displayed*
  int _counter; // time counter from n second to zero
  Timer _timer;
  var startTime;
  //lists for the Acceleromtre function
  List<List<dynamic>> rows = List<List<dynamic>>();
  List<List<dynamic>> recordsRows = List<List<dynamic>>();
  StreamSubscription accelStream; // it was  equal to null
  List<List<dynamic>> row = List();
  //-------------------Functions

  //hide/show table block
  void toggleTable(v) {
    setState(() {
      visble = v;
    });
  }

  //to catch up the sensor data
  startAccelerometer(handler) {
    accelStream = accelerometerEvents.listen((AccelerometerEvent event) {
      handler(event);
    });
  }

  // get the actuall time
  now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  //to pick accel data while time is running
  handleAccelEvent(event) {
    setState(() {
      x = event.x;
      y = event.y;
      z = event.z;
    });
    //In the fllwing lines : put the Acc data in a rowItem object
    //send the object to list of rows 'named recordRows' to prepare a csv file
    var t = now() - startTime; //to have the time we record each x y z
    AccelRecord rowItem = new AccelRecord(axeX: x, axeY: y, axeZ: z, tim: t);
    recordsRows.add(rowItem.toList());
  }

  //timer from N second to zero
  void startCountDown(counter, onEndcallBack) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print('tiiimergh  $_counter');
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        _timer.cancel();

        onEndcallBack();
      }
    });
  }

  //once he click on start recording: -take the time we started -time yan9os ,
  //activate the acc, show the table Data, stop recording
  startRecording() {
    startTime = now(); // to take the exact second we lunched the record
    startCountDown(_counter, () {
      stopRecording();
    });
    startAccelerometer(handleAccelEvent);
    toggleTable(true);
  }

  //once the timer finished: -hide table , send the Acc data to csv file
  stopRecording() {
    accelStream.cancel();
    toggleTable(false);
    recordsRows.add(rows); //  send the acc data to make the csv file
    getCsv(recordsRows); //check the csvMaker.dart
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
          //this widget is for the table of accel Data
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
                }),
            Visibility(
              child: TableData(counter: _counter, x: x, y: y, z: z),
              visible: visble,
            ),
          ]),
        ));
  }
}
