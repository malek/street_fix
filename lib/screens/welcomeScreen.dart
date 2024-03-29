import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_fix/screens/seeMapScreen.dart';
import 'package:street_fix/types/passedData.dart';
import 'package:street_fix/widgets/curved_widget.dart';
import 'package:street_fix/widgets/gardien_buttonWidget.dart';
import 'package:location/location.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  //---------Declaration:----------

  //fot inpute entred time
  final timeControler = TextEditingController();

  // time counter from n second to zero
  int _counter;
//for gps permission
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

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
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                CurvedWidget(
                  child: Container(
                      padding: const EdgeInsets.only(top: 70, left: 40),
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.yellow, Colors.white.withOpacity(1)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'BreeSerif',
                              color: Color(0xff6a515e),
                              letterSpacing: 6,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            'Set The Timer to start recording ..',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BreeSerif',
                              color: Color(0xff6a515e),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )),
                ),
              ]),
              Center(
                child: Column(
                  children: <Widget>[
                    Image(image: AssetImage('assets/timerIcon.png')),
                    SizedBox(height: 20),
                    Container(
                      width: 100.0,
                      height: 60,
                      child: TextField(
                        controller: timeControler,
                        decoration: InputDecoration(
                            hintText: 'Seconds',
                            hintStyle: TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xff6a515e), width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.brown[100], width: 2.0),
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
              SizedBox(height: 20),
              GradientButton(
                width: 150,
                height: 45,
                onPressed: () async {
                  setState(() {
                    _counter = int.parse(timeControler
                        .text); //to convert the text input to int -time-
                  });

                  _serviceEnabled = await location.serviceEnabled();
                  if (_serviceEnabled) {
                    _locationData = await location.getLocation();
                    var passedArguments = PassedArguments(
                        count: _counter, location: _locationData);

                    await Navigator.pushReplacementNamed(
                      context,
                      '/recordingScreen',
                      arguments: passedArguments,
                    );
                  }
                  if (!_serviceEnabled) {
                    _serviceEnabled = await location.requestService();
                    if (!_serviceEnabled) {
                      showAlertDialog(context, "You can't record without activating the GPS.");
                      return;
                    }
                  }

                  _permissionGranted = await location.hasPermission();
                  if (_permissionGranted == PermissionStatus.denied) {
                    _permissionGranted = await location.requestPermission();
                    await Navigator.pushReplacementNamed(
                        context, '/recordingScreen',
                        arguments: _counter);
                    if (_permissionGranted != PermissionStatus.granted) {
                      return;
                    }
                  }
                },
                text: Text(
                  'Record',
                  style: TextStyle(
                    fontFamily: 'BreeSerif',
                    color: Colors.yellowAccent,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                icon: Icon(
                  Icons.blur_on,
                  color: Colors.yellowAccent,
                ),
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GradientButton(
                        width: 150,
                        height: 45,
                        onPressed: () async {
                          _serviceEnabled = await location.serviceEnabled();
                          if (_serviceEnabled) {
                            _locationData = await location.getLocation();
                            var mapData = PassedArguments(
                                count: _counter, location: _locationData);

                            await Navigator.pushReplacementNamed(
                              context,
                              '/seeMapScreen',
                              arguments: mapData,
                            );
                          }
                          if (!_serviceEnabled) {
                            _serviceEnabled = await location.requestService();
                            if (!_serviceEnabled) {
                              showAlertDialog(context, 'Please activate the GPS.'); 
                              return;
                            }
                          }

                          _permissionGranted = await location.hasPermission();
                          if (_permissionGranted == PermissionStatus.denied) {
                            _permissionGranted =
                                await location.requestPermission();
                            await Navigator.pushReplacementNamed(
                                context, '/recordingScreen',
                                arguments: _counter);
                            if (_permissionGranted !=
                                PermissionStatus.granted) {
                              return;
                            }
                          }
                        },
                        text: Text(
                          'See Maps',
                          style: TextStyle(
                            fontFamily: 'BreeSerif',
                            color: Colors.yellowAccent,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                        icon: Icon(
                          Icons.map,
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

showAlertDialog(BuildContext context,description) {
  // Create button
  Widget okButton = RaisedButton(
    //color: Color(0xffffae88),
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text(
      'OK',
      style: TextStyle(
        fontFamily: 'BreeSerif',
        color: Color(0xff6a515e),
        fontSize: 20,
        letterSpacing: 1,
      ),
    ),
  );

  // Create AlertDialog
  var alert = AlertDialog(
    title: Center(
        child: Text(
      'Ooops',
      style: TextStyle(
        fontFamily: 'BreeSerif',
        color: Color(0xff6a515e),
        fontSize: 20,
        letterSpacing: 1,
      ),
    )),
    content: Text(
      description,
      style: TextStyle(
        fontFamily: 'BreeSerif',
        color: Colors.black,
        fontSize: 15,
        letterSpacing: 1,
      ),
    ),
    backgroundColor: Colors.yellow[100],
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
