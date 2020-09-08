import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  CustomDialog({this.title,this.description,this.buttonText});

  @override
  Widget build(BuildContext context) {
    return 
    showAlertDialog(context);
  }


showAlertDialog(BuildContext context) {
  // Create button
  Widget okButton = RaisedButton(
    //color: Color(0xffffae88),
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text(
      buttonText,
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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

}





