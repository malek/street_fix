import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/widgets/tableData.dart';
import 'package:street_fix/functions/csvMaker.dart';
import 'package:street_fix/functions/helper.dart';
import '../src/locations.dart' as locations;

import 'package:street_fix/widgets/gardien_button.dart'; //to add cancel recording

class Recording extends StatefulWidget {
  int counter;
  Recording({Key key, @required this.counter}) : super(key: key);

 

  @override
  _RecordingState createState() => _RecordingState(counter);
}

class _RecordingState extends State<Recording> {
  final Map<String, Marker> _markers = {};

  int counter;



//-----------Declarations--------------

  // for acc data
  double x = 0, y = 0, z = 0;
  //for the visibility of the block(Acc table, countDown number)
  bool visble = false;

  //column for x y z table * in the begining ykon displayed*
  Column results = Column();

  var startTime;
 Timer _timer;
  //lists for the Acceleromtre function
  List<List<dynamic>> recordsRows = List<List<dynamic>>();
  StreamSubscription accelStream; // it was  equal to null

  // ignore: sort_constructors_first
  _RecordingState(this.counter);
  @override
  void initState() {
    super.initState();

    startRecording();
  }

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
    var rowItem = AccelRecord(axeX: x, axeY: y, axeZ: z, tim: t);
    recordsRows.add(rowItem.toList());
  }

  startRecording() {
    startTime = now(); // to take the exact second we lunched the record
    startCountDown(
      declaredValue: _timer,
      initialValue: counter,
      onEnd: stopRecording,
      onTick: (cpt) => setState(() {
        counter = cpt;
      }),
    );
    startAccelerometer(handleAccelEvent);
  }

  //once the timer finished: -hide table , send the Acc data to csv file
  stopRecording() {
    accelStream.cancel();
    //  send the acc data to make the csv file
    saveToCsv(recordsRows, AccelRecord.getHeader()); //check the csvMaker.dart
  }

  nonsensefunction(){}
  cancelButton(){
   
     startCountDown(
       declaredValue: _timer,
       onEnd: nonsensefunction(),
     );
    
      }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.yellow, Colors.white.withOpacity(0.4)],
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Recor ',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'BreeSerif',
                      color: Color(0xff6a515e),
                      letterSpacing: 6,
                    ),
                  ),
                  Icon(
                    Icons.all_inclusive,
                    color: Color(0xffffae88),
                    size: 40,
                  ),
                  Text(
                    ' ding',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'BreeSerif',
                      color: Color(0xff6a515e),
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.3,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: const LatLng(0, 0),
                    zoom: 2,
                  ),
                  markers: _markers.values.toSet(),
                ),
              ),
              TableData(counter: counter, x: x, y: y, z: z),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GradientButton(
                        width: 140,
                        height: 45,
                        onPressed: () {
                          cancelButton();
                        Navigator.pushReplacementNamed(context, '/welcome');   
                        },
                        text: Text(
                          'Cancel ',
                          style: TextStyle(
                            fontFamily: 'BreeSerif',
                            color: Colors.yellowAccent,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        icon: Icon(
                          Icons.home,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
