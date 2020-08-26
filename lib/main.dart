import 'package:flutter/material.dart';
import 'package:street_fix/screens/recordShow.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      //initialRoute: '/home',
      routes: {
        '/recordShow': (context) => RecordShow(),
        '/main': (context) => Welcome(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('Not Found'),
              ));
        });
      },
      home: Welcome(),
    ));

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Street Fix'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
          child: RaisedButton(
              child: Text('Start Recording'),
              onPressed: () {
                Navigator.pushNamed(context, '/recordShow');
              })),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   GoogleMapController mapController;

//   final LatLng _center = const LatLng(45.521563, -122.677433);

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Maps Sample App'),
//           backgroundColor: Colors.green[700],
//         ),
//         body: Center(
//           child: Container(
//             width: 500,
//             height: 500,
//             child: GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _center,
//               zoom: 11.0,
//             ),
//           ),),
//         )
//       ),
//     );
//   }
// }
