import 'package:flutter/material.dart';
//import 'package:street_fix/screens/try.dart';
import 'package:street_fix/screens/recordShow.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    //initialRoute: '/home',
    routes: {
      //'/': (context) => FormScreen(),

      '/recordShow': (context) => RecordShow(),
      //'/try': (context) => RecordShow(),
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
