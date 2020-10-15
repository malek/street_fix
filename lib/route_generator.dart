import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:street_fix/screens/doneRecording.dart';
import 'package:street_fix/screens/recordingScreen.dart';
import 'package:street_fix/screens/seeMapScreen.dart';
import 'package:street_fix/screens/welcomeScreen.dart';
import 'package:street_fix/types/passedData.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Welcome());
      case '/recordingScreen':
        // Validation of correct data type
        if (args is PassedArguments) {
          return MaterialPageRoute(
            builder: (_) {
              var recording = Recording(
                recievedData: args,
              );
              return recording;
            },
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/welcomeScreen':
        return MaterialPageRoute(builder: (_) => Welcome());
      case '/doneRecordingScreen':
        return MaterialPageRoute(builder: (_) => DoneRecordingScreen());
      case '/seeMapScreen':
        // Validation of correct data type
        if (args is PassedArguments) {
          return MaterialPageRoute(
            builder: (_) {
              var maps = SeeMapScreen(
                mapData: args,
              );
              return maps;
            },
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
