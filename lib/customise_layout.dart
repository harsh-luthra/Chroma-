import 'dart:async';
import 'dart:convert';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/MarkersDataObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Color enabledMarkerColor = Colors.transparent;
  Color disabledMarkerColor = Colors.red;

  Color makerColorTopLeft = Colors.transparent;
  Color makerColorBottomLeft = Colors.transparent;
  Color makerColorTopRight = Colors.transparent;
  Color makerColorBottomRight = Colors.transparent;

  Color makerColorCenter = Colors.transparent;

  Color makerColorTopCenter = Colors.transparent;
  Color makerColorMiddleLeft = Colors.transparent;
  Color makerColorMiddleRight = Colors.transparent;
  Color makerColorBottomCenter = Colors.transparent;

  late MarkersDataObj markersDataObj;

  Color containerBorderColour = Colors.grey;
  Color containerColour = const Color.fromARGB(100,255,255,255);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    print(Duration.microsecondsPerSecond ~/ FPS);
    setState(() {
      cornerMargin = _currentSliderValue / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    double cornerSpace = screenWidth! * cornerMargin;
    return Scaffold(
      backgroundColor: selectedColor,
      body: Container(
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
                      markersDataObj.markerTopLeft = !markersDataObj.markerTopLeft;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerTopLeft),
                ),
              ),

              // TOP CENTER
              Positioned(
                top: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerTopCenter = !markersDataObj.markerTopCenter;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerTopCenter),
                ),
              ),

              // TOP RIGHT
              Positioned(
                top: cornerSpace,
                right: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerTopRight = !markersDataObj.markerTopRight;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerTopRight),
                ),
              ),


              // MIDDLE LEFT
              Positioned(
                left: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerMiddleLeft = !markersDataObj.markerMiddleLeft;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerMiddleLeft),
                ),
              ),

              // MIDDLE CENTER
              Positioned(
                top: screenHeight! * 0.435,
                bottom: screenHeight! * 0.435,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerCenter = ! markersDataObj.markerCenter;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerCenter),
                ),
              ),

              // MIDDLE RIGHT
              Positioned(
                right: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerMiddleRight = ! markersDataObj.markerMiddleRight;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerMiddleRight),
                ),
              ),


              // BOTTOM LEFT
              Positioned(
                bottom: cornerSpace,
                left: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerBottomLeft = !markersDataObj.markerBottomLeft;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerBottomLeft),
                ),
              ),

              // BOTTOM CENTER
              Positioned(
                bottom: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerBottomCenter = ! markersDataObj.markerBottomCenter;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerBottomCenter),
                ),
              ),

              // BOTTOM RIGHT
              Positioned(
                bottom: cornerSpace,
                right: cornerSpace,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerBottomRight = !markersDataObj.markerBottomRight;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerBottomRight),
                ),
              ),


              // Tutorial Text
              Positioned(
                bottom: screenHeight! * 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: containerColour,
                      border: Border.all(
                        color: containerBorderColour,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  alignment: Alignment.center,
                  //color: const Color.fromARGB(100, 255, 255, 255),
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
                  decoration: BoxDecoration(
                      color: containerColour,
                      border: Border.all(
                        color: containerBorderColour,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
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
                  decoration: BoxDecoration(
                      color: containerColour,
                      border: Border.all(
                        color: containerBorderColour,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //REST Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          HapticFeedback.mediumImpact();
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
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        saveData();
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder()),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 5),
                    //Exit Without Saving Button
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder()),
                      child: const Text('Exit'),
                    )
                  ],
                ),
              ),
            ],
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

    // makerColorTopLeft = enabledMarkerColor;
    // makerColorBottomLeft = enabledMarkerColor;
    // makerColorTopRight = enabledMarkerColor;
    // makerColorBottomRight = enabledMarkerColor;
    //
    // makerColorCenter = enabledMarkerColor;
    //
    // makerColorTopCenter = enabledMarkerColor;
    // makerColorMiddleLeft = enabledMarkerColor;
    // makerColorMiddleRight = enabledMarkerColor;
    // makerColorBottomCenter = enabledMarkerColor;

    markersDataObj = new MarkersDataObj();

    markersDataObj.markerTopLeft = true;
    markersDataObj. markerTopCenter = true;
    markersDataObj.markerTopRight = true;

    markersDataObj.markerMiddleLeft = true;
    markersDataObj.markerCenter = true;
    markersDataObj.markerMiddleRight = true;

    markersDataObj.markerBottomLeft = true;
    markersDataObj.markerBottomCenter = true;
    markersDataObj.markerBottomRight = true;

  }

  Widget markerWidget(bool isMarkerEnabled) {
    Color markerColor = enabledMarkerColor;
    double opacity = 1.0;
    if(isMarkerEnabled){
      markerColor = enabledMarkerColor;
      opacity = 1.0;
    }else{
      markerColor = disabledMarkerColor;
      opacity = 0.5;
    }
    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: markerColor,
        image: DecorationImage(
          opacity: opacity,
          image: selectedMarker,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Future<void> _dialogBuilder(BuildContext context) {
  //   return showDialog<void>(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return WillPopScope(
  //         onWillPop: () async => false,
  //         child: AlertDialog(
  //           title: const Text('Export'),
  //           content: const SingleChildScrollView(
  //             child: Text("Data Recorded"),
  //           ),
  //           actions: <Widget>[
  //             ElevatedButton(
  //               child: const Text('Export Accel'),
  //               onPressed: () {
  //                 List<String> header = [];
  //                 header.add('TimeStamp.');
  //                 header.add('AccelerometerValues');
  //                 exportCSV.myCSV(header, _accelerometerValues_List);
  //               },
  //             ),
  //             ElevatedButton(
  //               child: const Text('Export Gyro'),
  //               onPressed: () {
  //                 List<String> header = [];
  //                 header.add('TimeStamp.');
  //                 header.add('GyroscopeValues');
  //                 exportCSV.myCSV(header, _gyroscopeValues_List);
  //               },
  //             ),
  //             ElevatedButton(
  //               child: const Text('Cancel'),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void loadData() async {
    prefs = await SharedPreferences.getInstance();

    // Load Color
    final String? loadedColor = prefs.getString('selectedColor');
    print("Loaded Color $loadedColor");
    if (loadedColor != null) {
      String valueString = loadedColor.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      selectedColor = Color(value);
    } else {
      String? valueString = defaultColor?.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString!, radix: 16);
      selectedColor = Color(value);
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

   /* // Load Layout
    final String? loadedLayout = prefs.getString('selectedLayout');
    print("Loaded Layout $loadedMarker");
    if (loadedLayout != null) {
      if (loadedLayout == "1") {
        cornerMargin = 0.01;
      } else {
        cornerMargin = 0.01;
      }
    } else {
      cornerMargin = 0.01;
    }
    setState(() {
      cornerMargin = cornerMargin;
    });*/

    // Load Border Margin
    final String? loadedMargin = prefs.getString('cornerMargin');
    print("Loaded Margin $loadedMargin");
    if (loadedMargin != null) {
      cornerMargin = double.parse(loadedMargin);
    }else{
      cornerMargin = 0.01;
    }

    // Load Marker Size
    final String? loadedSize = prefs.getString('markerSize');
    print("Loaded Marker Size $loadedSize");
    if (loadedSize != null) {
      markerSize = double.parse(loadedSize);
    }else{
      markerSize = 40;
    }

    final String? markerDataobjString = prefs.getString('markerDataobjString');
    if (markerDataobjString != null) {
      print(markerDataobjString.toString());
      Map<String, dynamic> datamap = jsonDecode(markerDataobjString);
      markersDataObj = MarkersDataObj.fromJson(datamap);
    }else{
      markersDataObj =  MarkersDataObj();
      print(markerDataobjString.toString());
    }

    setState(() {
      selectedColor = selectedColor;
      selectedMarker = selectedMarker;
      cornerMargin = cornerMargin;
      markerSize = markerSize;
      _secondSliderValue = markerSize;
      _currentSliderValue = cornerMargin * 100;
      markersDataObj = markersDataObj;
      setStateOfMarkersFromLoadedData();
    });

  }

  void saveData() async {
    //saveMarkerObjData();
    await prefs.setString("markerDataobjString", json.encode(markersDataObj.toJson()));
    await prefs.setString('selectedLayout', "2");
    await prefs.setString('cornerMargin', cornerMargin.toString());
    await prefs.setString('markerSize', markerSize.toString());
    Future.delayed(const Duration(milliseconds: 500), () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) {
      //       return const MainScreen();
      //     },
      //   ),
      // );
      Navigator.popAndPushNamed(context, '/mainScreen');

    });
  }

  void setStateOfMarkersFromLoadedData(){
    if(markersDataObj.markerTopLeft){
      makerColorTopLeft = Colors.transparent;
    }else{
      makerColorTopLeft = Colors.red;
    }

    if(markersDataObj.markerTopCenter){
      makerColorTopCenter = Colors.transparent;
    }else{
      makerColorTopCenter = Colors.red;
    }

    if(markersDataObj.markerTopRight){
      makerColorTopRight = Colors.transparent;
    }else{
      makerColorTopRight = Colors.red;
    }

    if(markersDataObj.markerMiddleLeft){
      makerColorMiddleLeft = Colors.transparent;
    }else{
      makerColorMiddleLeft = Colors.red;
    }

    if(markersDataObj.markerCenter){
      makerColorCenter = Colors.transparent;
    }else{
      makerColorCenter = Colors.red;
    }

    if(markersDataObj.markerMiddleRight){
      makerColorMiddleRight = Colors.transparent;
    }else{
      makerColorMiddleRight = Colors.red;
    }

    if(markersDataObj.markerBottomLeft){
      makerColorBottomLeft = Colors.transparent;
    }else{
      makerColorBottomLeft = Colors.red;
    }

    if(markersDataObj.markerBottomCenter){
      makerColorBottomCenter = Colors.transparent;
    }else{
      makerColorBottomCenter = Colors.red;
    }

    if(markersDataObj.markerBottomRight){
      makerColorBottomRight = Colors.transparent;
    }else{
      makerColorBottomRight = Colors.red;
    }

    // makerColorTopLeft = Colors.transparent;
    // makerColorTopCenter = Colors.transparent;
    // makerColorTopRight = Colors.transparent;
    //
    // makerColorLeftCenter = Colors.transparent;
    // makerColorCenter = Colors.transparent;
    // makerColorRightCenter = Colors.transparent;
    //
    // makerColorBottomLeft = Colors.transparent;
    // makerColorBottomCenter = Colors.transparent;
    // makerColorBottomRight = Colors.transparent;
  }

}
