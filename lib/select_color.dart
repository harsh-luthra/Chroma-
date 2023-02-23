import 'dart:async';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/customise_layout.dart';
import 'package:chroma_plus_flutter/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectColor extends StatefulWidget {
  const SelectColor({Key? key}) : super(key: key);

  @override
  State<SelectColor> createState() => SelectColorState();
}

class SelectColorState extends State<SelectColor> {

  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.red_clr.toString();
  late SharedPreferences prefrences;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "1";
  bool showBack = false;

  Color selectedColor = const Color(0xffffffff);
  int selectedMarker = 1;
  int selectedLayout = 1;

  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  double? fontSize = 15;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    //listenAllSensors();
   // RepeatTest();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    fontSize = screenWidth! * 0.04;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConstants.Bg_Color,
        body: Container(
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
                      fontSize: fontSize! * 2,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
                 Text(
                  'by Scissor Films',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppConstants.txt_color_1,
                      fontFamily: 'Proxima Nova',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w300,
                      height: 1),
                ),
                SizedBox(height: screenHeight! * 0.13),
                Text(
                  selectTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppConstants.txt_color_1,
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      height: 1),
                ),
                SizedBox(height: screenHeight! * 0.025),
                // Color Columns
                selectWidget(),

                SizedBox(height: screenHeight! * 0.02),
                // Progress Bar
                progressBarSized(progressSize),
                SizedBox(height: screenHeight! * 0.01),
                // Progress Text
                bottomBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void repeatTest(){
    final periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
            print(DateTime.now().millisecondsSinceEpoch);
        // Update user about remaining time
      },
    );
    periodicTimer.cancel();
  }

  void stopRecord(){

  }

  void listenAllSensors(){
    accelerometerEvents.listen((AccelerometerEvent event) {
      print(event);
    });
    // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      print(event);
    });
    // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]
    gyroscopeEvents.listen((GyroscopeEvent event) {
      print(event);
    });
    // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
    magnetometerEvents.listen((MagnetometerEvent event) {
      print(event);
    });
  }

  Widget selectWidget() {
    if (progressInt == "1") {
      return colorPickerGroup();
    } else if (progressInt == "2") {
      return markerPickerGroup();
    } else if (progressInt == "3") {
      return layoutPickerGroup();
    } else {
      return layoutPickerGroup();
    }
  }

  Widget colorPickerGroup() {
    return SizedBox(
      width: screenWidth,
      height: screenHeight! *0.28,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              colorPaletteBox(AppConstants.green_clr, "Green"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              colorPaletteBox(AppConstants.blue_clr, "Blue"),
            ],
          ),
          SizedBox(
            height: screenHeight! * 0.0175,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              colorPaletteBox(AppConstants.black_clr, "Black"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              colorPaletteBox(currentColor, "Custom"),
            ],
          ),
        ],
      ),
    );
  }

  Widget markerPickerGroup() {
    return SizedBox(
      width: screenWidth,
      height: screenHeight! *0.28,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              markerPaletteBox(AppConstants.plusImg, "Cross"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              markerPaletteBox(AppConstants.triangleImg, "Triangle"),
            ],
          ),
         // SizedBox(height: (screenHeight! * 0.09) + 10 + 10)
        ],
      ),
    );
  }

  Widget layoutPickerGroup() {
    return SizedBox(
      width: screenWidth,
      height: screenHeight! *0.28,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              layoutPaletteBox(AppConstants.plusImg, "Standard"),
               SizedBox(
                width: screenWidth! * 0.03,
              ),
              layoutPaletteBox(AppConstants.triangleImg, "Custom"),
            ],
          ),
        ],
      ),
    );
  }

  void loadData() async {
    prefrences = await SharedPreferences.getInstance();
    final String? customColor = prefrences.getString('customColor');
    print("Loaded Color $customColor");
    if (customColor != null) {
      String valueString = customColor.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      currentColor = Color(value);
      print("Current Color $currentColor");
    } else {
      String? valueString = defaultColor?.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString!, radix: 16);
      currentColor = Color(value);
    }
    pickerColor = currentColor;
    setState(() {
      pickerColor = currentColor;
    });
  }

  void selectColorView() async {
    selectTitle = "Select Color";
    progressInt = "1";
    progressSize = 0.25;
    showBack = false;
  }

  void selectMarkerView() async {
    selectTitle = "Select Marker";
    progressInt = "2";
    progressSize = 0.5;
    showBack = true;
    print("Saved Color $selectedColor");
    await prefrences.setString('selectedColor', selectedColor.toString());
  }

  void selectLayout() async {
    selectTitle = "Select Layout";
    progressInt = "3";
    progressSize = 0.75;
    showBack = true;
    print("Saved Marker $selectedMarker");
    await prefrences.setString('selectedMarker', selectedMarker.toString());
  }

  void goToMain() async {
    await prefrences.setString('selectedLayout', selectedLayout.toString());
    print("Saved Layout $selectedLayout");
    Future.delayed(const Duration(milliseconds: 500), () {
      if(selectedLayout == 1){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const MainScreen();
            },
          ),
        );
      }else if(selectedLayout == 2){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const CustomiseLayout();
            },
          ),
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (progressInt == "2") {
      setState(() {
        selectColorView();
      });
    } else if (progressInt == "3") {
      setState(() {
        selectMarkerView();
      });
    } else if (progressInt == "1") {
      return true; //<-- SEE HERE
    }
    return false;
  }

  void goBack() {
    if (progressInt == "2") {
      setState(() {
        selectColorView();
      });
    } else if (progressInt == "3") {
      setState(() {
        selectMarkerView();
      });
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color', style: TextStyle(fontSize: fontSize),),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.buttonGreyColor,
                elevation: 0.0,
                minimumSize: const Size(60.0, 35.0),
                padding: const EdgeInsets.all(0.0),
              ),
              onPressed: () {
                setState(() {
                  selectedColor = pickerColor;
                  currentColor = pickerColor;
                  selectMarkerView();
                });
                Navigator.of(context).pop();
              },
              child: Text('Done', style: TextStyle(
                  color: AppConstants.buttonTxtColor,
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  height: 1),),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.buttonGreyColor,
                elevation: 0.0,
                minimumSize: const Size(70.0, 35.0),
                padding: const EdgeInsets.all(0.0),
              ),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                      color: AppConstants.buttonTxtColor,
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                      height: 1),),
            ),
          ],
        );
      },
    );
  }

  void changeColor(Color color) async {
    await prefrences.setString('customColor', color.toString());
    setState(() => pickerColor = color);
  }

  Widget colorPaletteBox(Color color, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    double? innerCircleSize = outerCircleSize * 0.34;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (title == "Custom") {
          _dialogBuilder(context);
        } else {
          setState(() {
            selectedColor = color;
            selectMarkerView();
          });
        }
      },
      child: Column(
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
                    topLeft: Radius.circular(39),
                    topRight: Radius.circular(39),
                    bottomLeft: Radius.circular(39),
                    bottomRight: Radius.circular(39),
                  ),
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenHeight! * 0.01,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: AppConstants.buttonTxtColor,
                fontFamily: 'Inter',
                fontSize: fontSize,
                // fontSize: 15,
                fontWeight: FontWeight.normal,
                height: 1),
          )
        ],
      ),
    );
  }

  Widget markerPaletteBox(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    //double? innerCircleSize = outerCircleSize * 0.34;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (title == "Cross") {
          setState(() {
            selectedMarker = 1;
            selectLayout();
          });
        } else if (title == "Triangle") {
          setState(() {
            selectedMarker = 2;
            selectLayout();
          });
        }
      },
      child: Column(
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
                  width: screenHeight! * 0.034,
                  height: screenHeight! * 0.034,
                  decoration: BoxDecoration(
                    image:
                    DecorationImage(image: showImage, fit: BoxFit.fitWidth),
                  )),
            ],
          ),
          SizedBox(
            height: screenHeight! * 0.01,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: const Color.fromRGBO(69, 69, 69, 1),
                fontFamily: 'Inter',
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
                height: 1),
          )
        ],
      ),
    );
  }

  Widget layoutPaletteBox(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (title == "Standard") {
          selectedLayout = 1;
        } else {
          selectedLayout = 2;
        }
        goToMain();
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: outerCircleSize,
                height: outerCircleSize * 1.5,
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
              layoutCenterBox(title),
            ],
          ),
          SizedBox(
            height: screenHeight! * 0.01,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: const Color.fromRGBO(69, 69, 69, 1),
                fontFamily: 'Inter',
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
        ],
      ),
    );
  }

  Widget layoutCenterBox(String title) {
    double? outerCircleSize = screenHeight! * 0.09;
    double? innerCircleSize = outerCircleSize * 1;
    if (title == "Standard") {
      return Container(
          width: innerCircleSize,
          height: innerCircleSize * 1.3,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AppConstants.standardImg,
              fit: BoxFit.contain,
            ),
          ));
    } else if (title == "Custom") {
      return Container(
          width: screenHeight! * 0.035,
          height: screenHeight! * 0.035,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AppConstants.customImg, fit: BoxFit.contain),
          ));
    } else {
      return Container();
    }
  }

  Widget progressBarSized(double progress) {
    double? progressFullWidth = screenWidth! * 0.42;
    return Stack(children: <Widget>[
      // Full Bar
      SizedBox(
        width: progressFullWidth,
        height: 9,
        child: Stack(children: <Widget>[
          Positioned(
              top: 0,
              left: 0,
              child: Container(
                  width: progressFullWidth,
                  height: 9,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(38.84709167480469),
                      topRight: Radius.circular(38.84709167480469),
                      bottomLeft: Radius.circular(38.84709167480469),
                      bottomRight: Radius.circular(38.84709167480469),
                    ),
                    color: Color.fromRGBO(111, 109, 109, 1),
                  ))),
        ]),
      ),
      // Progress
      SizedBox(
        width: progressFullWidth * progress,
        height: 9,
        child: Stack(children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              width: progressFullWidth,
              height: 9,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(38.84709167480469),
                  topRight: Radius.circular(38.84709167480469),
                  bottomLeft: Radius.circular(38.84709167480469),
                  bottomRight: Radius.circular(38.84709167480469),
                ),
                color: AppConstants.green_alt_clr,
              )),
        ]),
      ),
    ]);
  }

  Widget bottomBackButton() {
    double backButtonSize = screenWidth! * 0.1;
    if (showBack) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              goBack();
            },
            child: Container(
                alignment: Alignment.centerLeft,
                width: backButtonSize,
                height: backButtonSize,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AppConstants.backImg, fit: BoxFit.fitWidth),
                )),
          ),
          SizedBox(
              width: screenWidth! * 0.02
          ),
          Text(
            '$progressInt of 4',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: const Color.fromRGBO(105, 105, 105, 1),
                fontFamily: 'Inter',
                fontSize: fontSize,
                letterSpacing:
                    2 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          SizedBox(
              width: screenWidth! * 0.01
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: backButtonSize,
            height: backButtonSize,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              goBack();
            },
            child: Container(
              alignment: Alignment.centerLeft,
              width: backButtonSize,
              height: backButtonSize,
            ),
          ),
          SizedBox(
              width: screenWidth! * 0.09
          ),
          Text(
            '$progressInt of 4',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: const Color.fromRGBO(105, 105, 105, 1),
                fontFamily: 'Inter',
                fontSize: fontSize,
                letterSpacing:
                    2 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          SizedBox(
            width: screenWidth! * 0.09
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: backButtonSize,
            height: backButtonSize,
          ),
        ],
      );
    }
  }

}
