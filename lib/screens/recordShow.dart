import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/widgets/tableData.dart';
import 'package:street_fix/functions/csvMaker.dart';
import 'package:street_fix/functions/helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../src/locations.dart' as locations;

class RecordShow extends StatefulWidget {
  @override
  _RecordShowState createState() => _RecordShowState();
}

class _RecordShowState extends State<RecordShow> {

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  //-----------Declarations--------------

  // for acc data
  double x = 0, y = 0, z = 0;
  //for the visibility of the block(Acc table, countDown number)
  bool visble = false;
  //fot inpute entred time
  final timeControler = new TextEditingController();
  //column for x y z table * in the begining ykon displayed*
  Column results = new Column();
  // time counter from n second to zero
  int _counter;
  var startTime;

  //lists for the Acceleromtre function
  List<List<dynamic>> recordsRows = List<List<dynamic>>();
  StreamSubscription accelStream; // it was  equal to null

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
  //once he click on start recording: -take the time we started -time yan9os ,
  //activate the acc, show the table Data, stop recording
  startRecording() {
    startTime = now(); // to take the exact second we lunched the record
    startCountDown(
      initialValue: _counter,
      onEnd: stopRecording(),
      onTick: (cpt) => setState(() {
        _counter = cpt;
        
      }),
    );
    startAccelerometer(handleAccelEvent);
    toggleTable(true);
  }

  //once the timer finished: -hide table , send the Acc data to csv file
  stopRecording() {
    accelStream.cancel();
    toggleTable(false);
    //  send the acc data to make the csv file
    saveToCsv(recordsRows, AccelRecord.getHeader()); //check the csvMaker.dart
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
            Container(
              width: 400,
              height: 300,
              child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: const LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
        ),
            ),
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
                      decoration:  InputDecoration(
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




