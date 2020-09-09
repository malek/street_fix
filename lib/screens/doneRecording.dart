
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_fix/types/passedData.dart';
import 'package:street_fix/widgets/curved_widget.dart';
import 'package:street_fix/widgets/gardien_buttonWidget.dart';
import 'package:location/location.dart';

class DoneRecordingScreen extends StatefulWidget {
  @override
  _DoneRecordingScreenState createState() => _DoneRecordingScreenState();
}

class _DoneRecordingScreenState extends State<DoneRecordingScreen> {
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
  void initState() {
    super.initState();
    showAlertDialog(
        context,
        'Your recording is Done.',
        'Press the Send Data button in order to send the data to be worked on. \n Thank you.',
        'Deal');
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
                            'Hi Again!',
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
                    print('voilaaaa location');
                    print(_locationData);
                    await Navigator.pushReplacementNamed(
                      context,
                      '/recordingScreen',
                      arguments: passedArguments,
                    );
                  }
                  if (!_serviceEnabled) {
                    _serviceEnabled = await location.requestService();
                    if (!_serviceEnabled) {
                      showAlertDialog(context, 'oops',
                          "You can't record without activating the GPS.", 'Ok');
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: GradientButton(
                            width: 150,
                            height: 45,
                            onPressed: () {},
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
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GradientButton(
                            width: 150,
                            height: 45,
                            onPressed: () {},
                            text: Text(
                              'Send Data',
                              style: TextStyle(
                                fontFamily: 'BreeSerif',
                                color: Colors.yellowAccent,
                                fontSize: 15,
                                letterSpacing: 0,
                              ),
                            ),
                            icon: Icon(
                              Icons.map,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
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

showAlertDialog( contextt, title, description, buttontText) async {
  BuildContext context = await contextt;
  // Create button
  Widget okButton = RaisedButton(
    //color: Color(0xffffae88),
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text(
      buttontText,
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
      title,
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
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
