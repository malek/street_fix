import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/types/gyroRecord.dart';
import 'package:street_fix/widgets/tableData.dart';
import 'package:street_fix/functions/csvMaker.dart';
import 'package:street_fix/functions/helper.dart';
import '../src/locations.dart' as locations;
import 'package:location/location.dart';

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

//for the chart of accel
  List<double> traceAceeltX = [];
  List<double> traceAceeltY = [];
  List<double> traceAceeltZ = [];
  //for the chart of gyro
  List<double> traceGyroX = [];
  List<double> traceGyroY = [];
  List<double> traceGyroZ = [];

  // for acc data
  double xaccel = 0, yaccel = 0, zaccel = 0;
  // for acc gyro
  double xgyro = 0, ygyro = 0, zgyro = 0;
  //for the visibility of the block(Acc table, countDown number)
  bool visble = false;

  //column for x y z table * in the begining ykon displayed*
  Column results = Column();

  var startTime;
  Timer _timer;
  //lists for the Acceleromtre function
  List<List<dynamic>> recordsRows = List<List<dynamic>>();
  List<List<dynamic>> recordsRowsgyro = List<List<dynamic>>();
  List<List<dynamic>> rowcsvall = List<List<dynamic>>();
  StreamSubscription accelStream; // it was  equal to null
  StreamSubscription gyroStream;
  // ignore: sort_constructors_first
  _RecordingState(this.counter);

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
  // for the location and gps things

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  //to catch up the sensor data
  startAccelerometer(handler) {
    accelStream = accelerometerEvents.listen((AccelerometerEvent event) {
      handler(event);
    });
  }

  startGyroscope(handler) {
    gyroStream = gyroscopeEvents.listen((GyroscopeEvent event) {
      handler(event);
    });
  }

  //to pick accel data while time is running
  handleAccelEvent(event) {
    setState(() {
      xaccel = event.x;
      yaccel = event.y;
      zaccel = event.z;
    });
  }

  //to pick gyro data while time is running
  handleGyroscope(event) {
    setState(() {
      xgyro = event.x;
      ygyro = event.y;
      zgyro = event.z;
    });

    //In the fllwing lines : put the Acc data in a rowItem object
    //send the object to list of rows 'named recordRows' to prepare a csv file
    var t = now() - startTime; //to have the time we record each x y z
    var rowItem = AccelRecord(axeX: xaccel, axeY: yaccel, axeZ: zaccel, tim: t);
    var rowItemGyro = GyroRecord(axeX: xgyro, axeY: ygyro, axeZ: zgyro);
    recordsRows.add(rowItem.toList());
    recordsRowsgyro.add(rowItemGyro.toList());
  }

  //once the timer finished: -hide table , send the Acc data to csv file
  stopRecording() {
    accelStream.cancel();
    gyroStream.cancel();
    //  send the acc and gyro data to make the csv file

    for (var i = 0, j = 0;
        i < recordsRows.length && j < recordsRowsgyro.length;
        i++, j++) {
      rowcsvall
          .add([recordsRows[i], recordsRowsgyro[j]].expand((x) => x).toList());
    }

    var header = AccelRecord.getHeader() +
        GyroRecord.getHeader(); //check the csvMaker.dart
    saveToCsv(rowcsvall, header);
  }

  startRecording() {
    //func();
    getLocation();
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
    startGyroscope(handleGyroscope);
  }

  getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print('voilaaaa location');
    print(_locationData);
  }

  @override
  void initState() {
    super.initState();

    startRecording();
  }

  nonsensefunction() {}
  cancelButton() {
    startCountDown(
      declaredValue: _timer,
      onEnd: nonsensefunction(),
    );
  }

  Widget Chartt(value, traceColor) {
    var oscilloscope2 = Oscilloscope(
      showYAxis: true,
      yAxisMin: -12,
      yAxisMax: 12,
      padding: 0.0,
      backgroundColor: Colors.transparent,
      traceColor: traceColor,
      dataSet: value,
    );
    var oscilloscope = oscilloscope2;
    return oscilloscope;
  }

  Widget Osco(testGraph) {
    if (testGraph == 'accel') {
      traceAceeltX.add(xaccel);
      traceAceeltY.add(yaccel);
      traceAceeltZ.add(zaccel);
      return Stack(
        //alignment:new Alignment(x, y)
        children: <Widget>[
          Chartt(traceAceeltX, Color(0xff4f8a8b)),
          Chartt(traceAceeltY, Color(0xffffd31d)),
          Chartt(traceAceeltZ, Color(0xffb7472a)),
        ],
      );
    }
    if (testGraph == 'gyro') {
      traceGyroX.add(xgyro);
      traceGyroY.add(ygyro);
      traceGyroZ.add(zgyro);
      return Stack(
        //alignment:new Alignment(x, y)
        children: <Widget>[
          Chartt(traceGyroX, Color(0xff4f8a8b)),
          Chartt(traceGyroY, Color(0xffffd31d)),
          Chartt(traceGyroZ, Color(0xffb7472a)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ///TODO: need to fix the SingViewChildScroll
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
                  //markers: _markers.values.toSet(),
                ),
              ),
              //TableData(counter: counter, x: x, y: y, z: z),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xffffae88), Color(0xff6a515e)],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Osco('accel'),
                      ),
                    ),
                    Text(
                      'Accelerometre',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'BreeSerif',
                        color: Color(0xff6a515e),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xffffae88), Color(0xff6a515e)],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Osco('gyro'),
                      ),
                    ),
                    Text(
                      'Gyroscope',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'BreeSerif',
                        color: Color(0xff6a515e),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
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
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          color: Colors.transparent,
                          width: 140,
                          height: 45,
                          child: Row(
                            children: <Widget>[
                              Text(
                                'X ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'BreeSerif',
                                  color: Color(0xff6a515e),
                                ),
                              ),
                              Icon(Icons.timeline, color: Color(0xff4f8a8b)),
                              Text(
                                ' Y ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'BreeSerif',
                                  color: Color(0xff6a515e),
                                ),
                              ),
                              Icon(Icons.timeline, color: Color(0xffffd31d)),
                              Text(
                                ' Z ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'BreeSerif',
                                  color: Color(0xff6a515e),
                                ),
                              ),
                              Icon(Icons.timeline, color: Color(0xffb7472a)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
