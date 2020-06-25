import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/widgets/tableData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class RecordShow extends StatefulWidget {
  @override
  _RecordShowState createState() => _RecordShowState();
}

class _RecordShowState extends State<RecordShow> {
  String recordresult = '';
  String buttonText = 'record';
  double x = 0, y = 0, z = 0; // for acc data
  bool visble =
      false; // this var for the visibility of the block(Acc table, countDown number)
  List<AccelRecord> accelRecordData = new List();
  final timeControler = new TextEditingController();
  //column for x y z table * in the begining ykon displayed*
  Column results = new Column();
  int _counter; // time counter from n second to zero
  Timer _timer;
  var startTime;

  //-------------------Functions

  // csv file creation

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<List<dynamic>> recordsRows = List<List<dynamic>>();
  StreamSubscription accelStream; // it was  equal to null
  //List <List<dynamic>> row = List();

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('this is my path $path');
    return File('$path/Recording.csv');
  }

  Future<File> getCsv(rows) async {
    final file = await _localFile;

    String csv = const ListToCsvConverter().convert(rows);
    print(csv);

    // Write the file.
    return file.writeAsString('$csv');
  }


  //  title column header initialisation
  initHeaderColumn() {
    List<dynamic> headerTitle = List();
    headerTitle.add('Date');
    headerTitle.add('Axis X');
    headerTitle.add('Axis Y');
    headerTitle.add('Axis Z');

    recordsRows.add(headerTitle);
  }

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

    //get the sensor data and set then to the data types
  }

  // actuall time
  now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  //some changes
  handleAccelEvent(event) {
    setState(() {
      x = event.x;
      y = event.y;
      z = event.z;
    });
    //put the Acc data in a row and send the row to list of rows 'named recordRows' to prepare a csv file

    List toLista(AccelRecord r) {
      List row = List();
      row.add(r.tim);
      row.add(r.axeX);
      row.add(r.axeY);
      row.add(r.axeZ);

      return row;
    }

    //List<dynamic> row = List();
    //to have the time we record each x y z
    var t = now() - startTime;
    AccelRecord rowItem = new AccelRecord(axeX: x, axeY: y, axeZ: z, tim: t);

    recordsRows.add(toLista(rowItem));
  }

  //timer from N second to zero
  void startCountDown(counter, onEndcallBack) {
    initHeaderColumn();
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

  //once he click on start recording -time yan9os , activate the acc , send acc data , show the table Data , stop recording
  startRecording() {
    // to take the exct time we lunched the recording 
    startTime = now();
    startCountDown(_counter, () {
      stopRecording();
    });
    startAccelerometer(handleAccelEvent);
    toggleTable(true);
    //showTableAcc();
  }

  //once the timer finished: -hide table , send the Acc data to csv file
  stopRecording() {
    accelStream.cancel();
    toggleTable(false);

    recordsRows.add(rows);
    getCsv(recordsRows);
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

                  print('this isisisi $_counter');
                  //onclickStart = Container(
                  //child:                   );
                }),
            Visibility(
              child: TableData(counter: _counter, x: x, y: y, z: z),

              //createAccDataTable(),
              visible: visble,
            ),
          ]),
        ));
  }
}
