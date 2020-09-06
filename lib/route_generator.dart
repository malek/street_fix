import 'package:flutter/material.dart';
import 'package:street_fix/screens/recording.dart';
import 'package:street_fix/screens/welcome.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Welcome());
      case '/recording':
        // Validation of correct data type
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) {
              var recording = Recording(
                counter: args,
                );
              return recording;
            },
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/welcome':
        return MaterialPageRoute(builder: (_) => Welcome());
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