
import 'package:flutter/material.dart';
import 'package:street_fix/route_generator.dart';
void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('Not Found'),
              ));
        });
      },
    ));

