import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:street_fix/types/passedData.dart';

class SeeMapScreen extends StatefulWidget {

PassedArguments mapData;
  SeeMapScreen({Key key, @required this.mapData}) : super(key: key);

  @override
  _SeeMapScreenState createState() => _SeeMapScreenState(mapData);
}

class _SeeMapScreenState extends State<SeeMapScreen> {

PassedArguments mapData;

LocationData currentLocation;
double currentLatitude, currentLongitude;
  _SeeMapScreenState(this.mapData);
 

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentLatitude =mapData.location.latitude;
    currentLongitude = mapData.location.longitude;
  }

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_return, color: Colors.black,),
          onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/welcomeScreen' ),
        ),
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
              Text(
                '  Road Quality Map ',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'BreeSerif',
                  color: Color(0xff6a515e),
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 10),
              Container(
                
                height: MediaQuery.of(context).size.height * 0.895,
                child: GoogleMap(
                  
                  mapType: MapType.normal,
                  // onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLatitude,
                        currentLongitude),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
