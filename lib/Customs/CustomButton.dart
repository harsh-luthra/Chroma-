import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget thechild;
  final double width;
  final double height;
  final Function() theaction;

  const CustomButton({
    Key? key,
    required this.thechild,
    this.width = double.infinity,
    this.height = 50.0,
    required this.theaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: theaction,
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        elevation: 4.0,
        minimumSize: Size(88.0, 45.0),
        padding: const EdgeInsets.all(0.0),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0.1,
                0.8,
                0.9
              ],
              colors: [
                Color.fromARGB(255, 186, 252, 244),
                Color.fromARGB(255, 55, 183, 230),
                Color.fromARGB(255, 49, 175, 230),
              ]),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 45.0),
          alignment: Alignment.center,
          child: thechild,
        ),
      ),
    );
  }
}