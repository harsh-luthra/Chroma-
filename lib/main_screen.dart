import 'dart:ffi';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  // create some values
  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.green_clr.toString();
  late var prefs;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "1";
  bool showBack = false;

  double _currentSliderValue = 10;
  double _secondSliderValue = 20;

  Color selectedColor = Color(0xffffffff);
  AssetImage selectedMarker = AppConstants.plusImg;
  double cornerMargin = 0.01;

  double markerSize = 20;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    double cornerSpace = screenWidth! * cornerMargin;
    return Scaffold(
      backgroundColor: selectedColor,
      body: GestureDetector(
        onTap: () {
          print("On Tap");
        },
        onDoubleTap: () {
          print("On Double Tap");
        },
        onLongPress: () {
          print("On Long Press");
        },
        child: Container(
          decoration: BoxDecoration(
            color: selectedColor,
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: cornerSpace,
                  left: cornerSpace,
                  child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: selectedMarker,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                Positioned(
                  bottom: cornerSpace,
                  left: cornerSpace,
                  child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: selectedMarker,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                Positioned(
                  top: cornerSpace,
                  right: cornerSpace,
                  child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: selectedMarker,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                Positioned(
                  bottom: cornerSpace,
                  right: cornerSpace,
                  child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: selectedMarker,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                Positioned(
                  bottom: screenHeight! * 0.45,
                  child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: selectedMarker,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                // RePosition Corner
                Positioned(
                  bottom: screenHeight! * 0.35,
                  child: Container(
                    width: screenWidth!*0.7,
                    height: 20,
                    child: Slider(
                      value: _currentSliderValue,
                      min: 1,
                      max: 20,
                      divisions: 20,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          print(value);
                          _currentSliderValue = value;
                          cornerMargin = _currentSliderValue / 100;
                        });
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight! * 0.25,
                  child: Container(
                    width: screenWidth!*0.7,
                    height: 20,
                    child: Slider(
                      value: _secondSliderValue,
                      min: 20,
                      max: 60,
                      divisions: 10,
                      label: _secondSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          print(value);
                          _secondSliderValue = value;
                          markerSize = _secondSliderValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadData() async {
    prefs = await SharedPreferences.getInstance();

    // Load Color
    final String? loadedColor = prefs.getString('selectedColor');
    print("Loaded Color $loadedColor");
    if (loadedColor != null) {
      String valueString = loadedColor.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      selectedColor = Color(value);
      setState(() {
        selectedColor = Color(value);
      });
    } else {
      String? valueString = defaultColor?.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString!, radix: 16);
      selectedColor = Color(value);
      setState(() {
        selectedColor = Color(value);
      });
    }

    // Load Marker
    final String? loadedMarker = prefs.getString('selectedMarker');
    print("Loaded Marker $loadedMarker");
    if (loadedMarker != null) {
      if (loadedMarker == "1") {
        selectedMarker = AppConstants.plusImg;
      } else {
        selectedMarker = AppConstants.triangleImg;
      }
    } else {
      selectedMarker = AppConstants.plusImg;
    }
    setState(() {
      selectedMarker = selectedMarker;
    });

    // Load Layout
    final String? loadedLayout = prefs.getString('selectedLayout');
    print("Loaded Layout $loadedMarker");
    if (loadedLayout != null) {
      if (loadedLayout == "1") {
        cornerMargin = 0.01;
      } else {
        cornerMargin = 0.05;
      }
    } else {
      cornerMargin = 0.01;
    }
    setState(() {
      cornerMargin = cornerMargin;
    });
  }
}
