
import 'package:flutter/material.dart';
import 'package:street_fix/route_generator.dart';
import 'package:street_fix/screens/welcome.dart';
void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      //initialRoute: '/home',
      // routes: {
      //   '/recordShow': (context) => RecordShow(),
      //   '/recording': (context) => Recording(),
      //   '/main': (context) => Welcome(),
      //   //'/welcome': (context) => Welcome(),
      // },
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
      //home: Recording(),
      home: Welcome(),
    ));

