import 'package:flutter/material.dart';

class GuessButton extends StatelessWidget {
  String mode;
  String value;
  num confidence;
  Function onPressed;
  GuessButton({this.mode, this.value, this.confidence, this.onPressed})
      : super();
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(200, 100, 50, 50),
              border:
                  Border.all(color: Color.fromARGB(100, 0, 0, 0), width: 30)),
          child: Column(children: <Widget>[
            value == null
                ? Text(
                    'GUESS',
                    style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(200, 255, 255, 255)),
                  )
                : Text(
                    '$value',
                    style: TextStyle(
                        fontSize: 50,
                        color: Color.fromARGB(200, 255, 255, 255)),
                  ),
            value != null
                ? Text(
                    '$confidence',
                    style: TextStyle(
                        fontSize: 8, color: Color.fromARGB(200, 255, 255, 255)),
                  )
                : Container(),
          ]),
        ));
  }
}
