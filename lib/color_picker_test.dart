import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class color_picker_test extends StatefulWidget {
  const color_picker_test({Key? key}) : super(key: key);

  @override
  State<color_picker_test> createState() => _color_picker_testState();
}

class _color_picker_testState extends State<color_picker_test> {
  // create some values
  double? screenWidth;
  double? screenHeight;

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppConstants.Bg_Color,
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppConstants.Bg_Color,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'CHROMA+',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: AppConstants.txt_color_1,
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  _dialogBuilder(context);
                  print("Custom");
                  AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                  );
                },
                child: colorPalette(currentColor, "Custom"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget colorPalette(Color color, String title) {
    double? outerCircleCorner = 18;
    double? outerCircleSize = screenHeight! * 0.09;
    double? innerCircleSize = outerCircleSize * 0.34;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: outerCircleSize,
              height: outerCircleSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(outerCircleCorner),
                  topRight: Radius.circular(outerCircleCorner),
                  bottomLeft: Radius.circular(outerCircleCorner),
                  bottomRight: Radius.circular(outerCircleCorner),
                ),
                color: AppConstants.Alt_Color,
              ),
            ),
            Container(
              width: innerCircleSize,
              height: innerCircleSize,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(38.84709167480469),
                  topRight: Radius.circular(38.84709167480469),
                  bottomLeft: Radius.circular(38.84709167480469),
                  bottomRight: Radius.circular(38.84709167480469),
                ),
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
              color: Color.fromRGBO(69, 69, 69, 1),
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.normal,
              height: 1),
        )
      ],
    );
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
}
