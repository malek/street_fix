import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:street_fix/model/street_fix_Request.dart';
import 'package:street_fix/model/street_fix_Response.dart';
import 'package:street_fix/network_utils/street_fix_utils.dart';
import 'package:street_fix/types/accelRecord.dart';
import 'package:street_fix/types/gpsRecord.dart';
import 'package:street_fix/types/gyroRecord.dart';
import 'package:street_fix/types/passedData.dart';
import 'package:street_fix/functions/csvMaker.dart';
import 'package:street_fix/functions/helper.dart';
import '../src/locations.dart' as locations;
import 'package:location/location.dart';
import 'package:street_fix/widgets/gardien_buttonWidget.dart'; //to add cancel recording

class Recording extends StatefulWidget {
  PassedArguments recievedData;
  Recording({Key key, @required this.recievedData}) : super(key: key);
  @override
  _RecordingState createState() => _RecordingState(recievedData);
}

class _RecordingState extends State<Recording> {
  StreetfixRequest streetData;

  final Map<String, Marker> _markers = {};

  PassedArguments recievedData;
//-----------Declarations--------------

//for the chart of accel
  List<double> traceAceeltX = [];
  List<double> traceAceeltY = [];
  List<double> traceAceeltZ = [];
  //for the chart of gyro
  List<double> traceGyroX = [];
  List<double> traceGyroY = [];
  List<double> traceGyroZ = [];

  // for acc data, gyro data , gps data
  double xaccel = 0, yaccel = 0, zaccel = 0;
  double xgyro = 0, ygyro = 0, zgyro = 0;
  double currentLatitude = 0, currentLongitude = 0, currentspeed = 0;

  var startTime;
  Timer _timer;

  //to save data once cancled
  bool saveCancel = true;

  //lists for the Acceleromtre/Gyroscope/Gps function
  List<List<dynamic>> recordsRows = <List<dynamic>>[];

  StreamSubscription accelStream;
  StreamSubscription gyroStream;
  StreamSubscription locationStream;
  Location location = Location();

  // ignore: sort_constructors_first
  _RecordingState(this.recievedData);

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

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission Denied');
      }
    }
  }

  //to catch up the sensors -accel, gyro, gps- data
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

  startGps(handler) {
    location.onLocationChanged.listen((LocationData currentLocation) {
      handler(currentLocation);
      // Use current location
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

  //to pick gps data while time is running
  handleGpsEvent(currentLocation) {
    currentLatitude = currentLocation.latitude;
    currentLongitude = currentLocation.longitude;
    currentspeed = currentLocation.speed;
  }

  //to pick gyro data while time is running
  handleGyroscope(event) {
    setState(() {
      xgyro = event.x;
      ygyro = event.y;
      zgyro = event.z;
    });

    //In the fllwing lines : put the Acc/gyro/gps data in a rows object
    //send the object to list of rows 'named recordRows' to prepare a csv file

    var t = now() - startTime; //to have the time we record each x y z
    var rowItemAccel =
        AccelRecord(axeX: xaccel, axeY: yaccel, axeZ: zaccel, tim: t);
    var rowItemGyro = GyroRecord(axeX: xgyro, axeY: ygyro, axeZ: zgyro);
    var rowGpsItem = GpsRecord(
        lat: currentLatitude, long: currentLongitude, speed: currentspeed);

    recordsRows.add(
        rowItemAccel.toList() + rowItemGyro.toList() + rowGpsItem.toList());
  }

//to bring data and send from api
  post(csv) async {
    print("in post method");
    var streetData = StreetfixRequest(csv: csv);
    // First method
    Response response = await StreetfixUtils.postData(streetData);
    print("after resposnse declrtaion");
    if (response.statusCode == 200) {
      //Successful
      print("YAY tmchhaat");
      print(response.body);
      return streetfixFromJson(response.body);
    }
  }

//once the timer finished: send the accel/gyro/gps row to csv - show DonePage
  stopRecording({saveResults = true}) async {
    _timer.cancel();
    accelStream.cancel();
    gyroStream.cancel();
//  locationStream.cancel();
    ///TODO: cancel location thing
    if (saveCancel) {
      var header = AccelRecord.getHeader() +
          GyroRecord.getHeader() +
          GpsRecord.getHeader(); //check the csvMaker.dart
      var csv = saveToCsv(recordsRows, header);
      var res = post(csv);
      if (saveResults) //this means that he didnt press the cancel buttn
      {
        await Navigator.pushReplacementNamed(context, '/doneRecordingScreen');
      }
    }
  }

  startRecording() async {
    setState(() {
      currentLatitude = recievedData.location.latitude;
      currentLongitude = recievedData.location.longitude;
      currentspeed = recievedData.location.speed;
    });
    startTime = now(); // to take the exact second we lunched the record
    _timer = startCountDown(
      timer: _timer,
      initialValue: recievedData.count,
      onEnd: stopRecording,
      onTick: (cpt) => setState(() {
        recievedData.count = cpt;
      }),
    );

    startAccelerometer(handleAccelEvent);
    startGyroscope(handleGyroscope);
    startGps(handleGpsEvent);
    getCurrentLocation();
  }

  @override
  void initState() {
    super.initState();
    startRecording();
  }

  Future cancelButton() async => stopRecording(
        saveResults: false,
      );

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
    } else {
      return Text('Error To load Charts');
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
                  mapType: MapType.normal,
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
                            _timer.cancel();
                            accelStream.cancel();
                            gyroStream.cancel();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Center(
                                      child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'BreeSerif',
                                      color: Color(0xff6a515e),
                                      fontSize: 20,
                                      letterSpacing: 1,
                                    ),
                                  )),
                                  content: Text(
                                    'Do You want to save the recording data ?',
                                    style: TextStyle(
                                      fontFamily: 'BreeSerif',
                                      color: Colors.black,
                                      fontSize: 15,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  backgroundColor: Colors.yellow[100],
                                  actions: <Widget>[
                                    
                                    Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        RaisedButton(
                                          //color: Color(0xffffae88),
                                          onPressed: () {
                                            setState(() {
                                              saveCancel = true;
                                            });
                                            Navigator.of(context).pop();
                                            cancelButton();
                                            Navigator.pushReplacementNamed(
                                                context, '/welcomeScreen');
                                          },
                                          child: Text(
                                            'YES',
                                            style: TextStyle(
                                              fontFamily: 'BreeSerif',
                                              color: Color(0xff6a515e),
                                              fontSize: 20,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 178,),
                                        RaisedButton(
                                          //color: Color(0xffffae88),
                                          onPressed: () {
                                            saveCancel = false;
                                            Navigator.of(context).pop();
                                            cancelButton();
                                            Navigator.pushReplacementNamed(
                                                context, '/welcomeScreen');
                                          },
                                          child: Text(
                                            'NO',
                                            style: TextStyle(
                                              fontFamily: 'BreeSerif',
                                              color: Color(0xff6a515e),
                                              fontSize: 20,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
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
