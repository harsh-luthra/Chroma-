import 'dart:async';
import 'dart:ffi';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class CustomiseLayout extends StatefulWidget {
  const CustomiseLayout({Key? key}) : super(key: key);

  @override
  State<CustomiseLayout> createState() => CustomiseLayoutState();
}

class CustomiseLayoutState extends State<CustomiseLayout> {
  // create some values
  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.green_clr.toString();
  late var prefs;

  double FPS = 30;

  late Timer timer;
  bool stopRecordingBool = false;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "1";
  bool showBack = false;

  double _currentSliderValue = 1;
  double _secondSliderValue = 40;

  Color selectedColor = const Color(0xffffffff);
  AssetImage selectedMarker = AppConstants.plusImg;
  double cornerMargin = 0.01;

  double markerSize = 40;

  List<double>? _accelerometerValues;
  List<List<String>> _accelerometerValues_List = [];
  late String old_accelerometerValues = "";

  List<double>? _gyroscopeValues;
  List<List<String>> _gyroscopeValues_List = [];

  Color enabledMarkerColor = Colors.transparent;
  Color disabledMarkerColor = Colors.red;

  Color makerColorTopLeft = Colors.transparent;
  Color makerColorBottomLeft = Colors.transparent;
  Color makerColorTopRight = Colors.transparent;
  Color makerColorBottomRight = Colors.transparent;

  Color makerColorCenter = Colors.transparent;

  Color makerColorTopCenter = Colors.transparent;
  Color makerColorLeftCenter = Colors.transparent;
  Color makerColorRightCenter = Colors.transparent;
  Color makerColorBottomCenter = Colors.transparent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    print(Duration.microsecondsPerSecond ~/ FPS);
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
                // TOP LEFT
                Positioned(
                  top: cornerSpace,
                  left: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorTopLeft == enabledMarkerColor) {
                          makerColorTopLeft = disabledMarkerColor;
                        } else {
                          makerColorTopLeft = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorTopLeft),
                  ),
                ),
                // BOTTOM LEFT
                Positioned(
                  bottom: cornerSpace,
                  left: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorBottomLeft == enabledMarkerColor) {
                          makerColorBottomLeft = disabledMarkerColor;
                        } else {
                          makerColorBottomLeft = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorBottomLeft),
                  ),
                ),
                // TOP RIGHT
                Positioned(
                  top: cornerSpace,
                  right: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorTopRight == enabledMarkerColor) {
                          makerColorTopRight = disabledMarkerColor;
                        } else {
                          makerColorTopRight = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorTopRight),
                  ),
                ),
                // BOTTOM RIGHT
                Positioned(
                  bottom: cornerSpace,
                  right: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorBottomRight == enabledMarkerColor) {
                          makerColorBottomRight = disabledMarkerColor;
                        } else {
                          makerColorBottomRight = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorBottomRight),
                  ),
                ),
                // CENTER
                Positioned(
                  top: screenHeight! * 0.435,
                  bottom: screenHeight! * 0.435,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorCenter == enabledMarkerColor) {
                          makerColorCenter = disabledMarkerColor;
                        } else {
                          makerColorCenter = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorCenter),
                  ),
                ),

                // TOP CENTER
                Positioned(
                  top: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorTopCenter == enabledMarkerColor) {
                          makerColorTopCenter = disabledMarkerColor;
                        } else {
                          makerColorTopCenter = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorTopCenter),
                  ),
                ),

                // LEFT CENTER
                Positioned(
                  left: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorLeftCenter == enabledMarkerColor) {
                          makerColorLeftCenter = disabledMarkerColor;
                        } else {
                          makerColorLeftCenter = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorLeftCenter),
                  ),
                ),

                // RIGHT CENTER
                Positioned(
                  right: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorRightCenter == enabledMarkerColor) {
                          makerColorRightCenter = disabledMarkerColor;
                        } else {
                          makerColorRightCenter = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorRightCenter),
                  ),
                ),

                // BOTTOM CENTER
                Positioned(
                  bottom: cornerSpace,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (makerColorBottomCenter == enabledMarkerColor) {
                          makerColorBottomCenter = disabledMarkerColor;
                        } else {
                          makerColorBottomCenter = enabledMarkerColor;
                        }
                      });
                    },
                    child: markerWidget(makerColorBottomCenter),
                  ),
                ),

                // Tutorial Text
                Positioned(
                  bottom: screenHeight! * 0.6,
                  child: Container(
                    alignment: Alignment.center,
                    color: const Color.fromARGB(100, 255, 255, 255),
                    height: 70,
                    width: screenWidth!*0.95,
                    child: const Text(
                      "Long Press Markers To Toggle Their Visibility\n\n(Red Markers are Not Visible in Layout)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Proxima Nova',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1),
                    ),
                  ),
                ),

                // SLIDERS
                // Marker Margin Slider
                Positioned(
                  bottom: screenHeight! * 0.375,
                  child: Container(
                    color: const Color.fromARGB(100, 255, 255, 255),
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 7),
                        const Text(
                          'Corner Margin',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1),
                        ),
                        SizedBox(
                          width: screenWidth! * 0.7,
                          height: 20,
                          child: Slider(
                            value: _currentSliderValue,
                            min: 1,
                            max: 20,
                            divisions: 20,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                //print(value);
                                _currentSliderValue = value;
                                cornerMargin = _currentSliderValue / 100;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Marker Size Slider
                Positioned(
                  bottom: screenHeight! * 0.3,
                  child: Container(
                    transformAlignment: Alignment.center,
                    color: const Color.fromARGB(100, 255, 255, 255),
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        const Text(
                          'Marker Size',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1),
                        ),
                        SizedBox(
                          width: screenWidth! * 0.7,
                          height: 20,
                          child: Slider(
                            value: _secondSliderValue,
                            min: 20,
                            max: 60,
                            divisions: 10,
                            label: _secondSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                //print(value);
                                _secondSliderValue = value;
                                markerSize = _secondSliderValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Positioned(
                  bottom: screenHeight! * 0.22,
                  left: screenWidth! * 0.04,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //REST Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            resetSettings();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 5),
                      // Save & Exit Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: const Text('Save & Exit'),
                      ),
                      const SizedBox(width: 5),
                      //Exit Without Saving Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: const Text('Exit Without Saving'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetSettings() {
    _currentSliderValue = 1;
    _secondSliderValue = 40;
    markerSize = _secondSliderValue;
    cornerMargin = _currentSliderValue / 100;

    makerColorTopLeft = enabledMarkerColor;
    makerColorBottomLeft = enabledMarkerColor;
    makerColorTopRight = enabledMarkerColor;
    makerColorBottomRight = enabledMarkerColor;

    makerColorCenter = enabledMarkerColor;

    makerColorTopCenter = enabledMarkerColor;
    makerColorLeftCenter = enabledMarkerColor;
    makerColorRightCenter = enabledMarkerColor;
    makerColorBottomCenter = enabledMarkerColor;
  }

  Widget markerWidget(Color markerColor) {
    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: markerColor,
        image: DecorationImage(
          opacity: 0.6,
          image: selectedMarker,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Export'),
            content: const SingleChildScrollView(
              child: Text("Data Recorded"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Export Accel'),
                onPressed: () {
                  List<String> header = [];
                  header.add('TimeStamp.');
                  header.add('AccelerometerValues');
                  exportCSV.myCSV(header, _accelerometerValues_List);
                },
              ),
              ElevatedButton(
                child: const Text('Export Gyro'),
                onPressed: () {
                  List<String> header = [];
                  header.add('TimeStamp.');
                  header.add('GyroscopeValues');
                  exportCSV.myCSV(header, _gyroscopeValues_List);
                },
              ),
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
