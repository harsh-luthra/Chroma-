import 'dart:async';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/customise_layout.dart';
import 'package:chroma_plus_flutter/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectColorBkup extends StatefulWidget {
  const SelectColorBkup({Key? key}) : super(key: key);

  @override
  State<SelectColorBkup> createState() => SelectColorBkupState();
}

class SelectColorBkupState extends State<SelectColorBkup> {
  // create some values
  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.red_clr.toString();
  late var prefrences;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "1";
  bool showBack = false;

  Color selectedColor = const Color(0xffffffff);
  int selectedMarker = 1;
  int selectedLayout = 1;

  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    //listenAllSensors();
    // RepeatTest();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
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
                const Text(
                  'CHROMA+',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppConstants.txt_color_1,
                      fontFamily: 'Inter',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
                const Text(
                  'by Scissor Films',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppConstants.txt_color_1,
                      fontFamily: 'Proxima Nova',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      height: 1),
                ),
                SizedBox(height: screenHeight! * 0.13),
                Text(
                  selectTitle,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: AppConstants.txt_color_1,
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Color Columns
                SelectWidget(),
                //colorPickerGroup(),
                //markerPickerGroup(),
                const SizedBox(height: 20),
                // Progress Bar
                progressBarSized(progressSize),
                const SizedBox(height: 5),
                // Progress Text
                bottomBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void RepeatTest(){
    final periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        print(DateTime.now().millisecondsSinceEpoch);
        // Update user about remaining time
      },
    );
    periodicTimer.cancel();
  }

  void StopRecord(){

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

  Widget SelectWidget() {
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            colorPaletteBox(AppConstants.green_clr, "Green"),
            const SizedBox(
              width: 10,
            ),
            colorPaletteBox(AppConstants.blue_clr, "Blue"),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            colorPaletteBox(AppConstants.black_clr, "Black"),
            const SizedBox(
              width: 10,
            ),
            colorPaletteBox(currentColor, "Custom"),
          ],
        ),
      ],
    );
  }

  Widget markerPickerGroup() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            markerPaletteBox(AppConstants.plusImg, "Cross"),
            const SizedBox(
              width: 10,
            ),
            markerPaletteBox(AppConstants.sfCircleImg, "Triangle"),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            markerPaletteBox_fake(),
            const SizedBox(
              width: 10,
            ),
            markerPaletteBox_fake(),
          ],
        ),
        // SizedBox(height: (screenHeight! * 0.09) + 10 + 10)
      ],
    );
  }

  Widget layoutPickerGroup() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            layoutPaletteBox(AppConstants.plusImg, "Standard"),
            const SizedBox(
              width: 10,
            ),
            layoutPaletteBox(AppConstants.sfCircleImg, "Custom"),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(height: (screenHeight! * 0.09) / 1.5 + 9)
      ],
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

  void SelectColorView() async {
    selectTitle = "Select Color";
    progressInt = "1";
    progressSize = 0.25;
    showBack = false;
  }

  void SelectMarkerView() async {
    selectTitle = "Select Marker";
    progressInt = "2";
    progressSize = 0.5;
    showBack = true;
    print("Saved Color $selectedColor");
    await prefrences.setString('selectedColor', selectedColor.toString());
  }

  void SelectLayout() async {
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
        SelectColorView();
      });
    } else if (progressInt == "3") {
      setState(() {
        SelectMarkerView();
      });
    } else if (progressInt == "1") {
      return true; //<-- SEE HERE
    }
    return false;
  }

  void goBack() {
    if (progressInt == "2") {
      setState(() {
        SelectColorView();
      });
    } else if (progressInt == "3") {
      setState(() {
        SelectMarkerView();
      });
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color', style: TextStyle(fontSize: 15),),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(65, 0, 0, 0),
                elevation: 0.0,
                minimumSize: const Size(60.0, 35.0),
                padding: const EdgeInsets.all(0.0),
              ),
              onPressed: () {
                setState(() {
                  selectedColor = pickerColor;
                  currentColor = pickerColor;
                  SelectMarkerView();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Done', style: TextStyle(
                  color: Color.fromRGBO(69, 69, 69, 1),
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  height: 1),),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(65, 0, 0, 0),
                elevation: 0.0,
                minimumSize: const Size(70.0, 35.0),
                padding: const EdgeInsets.all(0.0),
              ),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(
                  color: Color.fromRGBO(69, 69, 69, 1),
                  fontFamily: 'Inter',
                  fontSize: 15,
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
            SelectMarkerView();
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
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(69, 69, 69, 1),
                fontFamily: 'Inter',
                fontSize: 15,
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
            SelectLayout();
          });
        } else if (title == "Triangle") {
          setState(() {
            selectedMarker = 2;
            SelectLayout();
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
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(69, 69, 69, 1),
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                height: 1),
          )
        ],
      ),
    );
  }

  Widget markerPaletteBox_fake() {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    //double? innerCircleSize = outerCircleSize * 0.34;
    return GestureDetector(
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
                  color: Colors.transparent,
                ),
              ),
              Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(

                  )),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "",
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(69, 69, 69, 1),
                fontFamily: ' ',
                fontSize: 15,
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
    //double? innerCircleSize = outerCircleSize * 1;
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
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(69, 69, 69, 1),
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          const SizedBox(
            height: 4,
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
          width: innerCircleSize * 0.3,
          height: innerCircleSize * 0.3,
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
    double backButtonSize = 36;
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
          const SizedBox(
            width: 10,
          ),
          Text(
            '$progressInt of 4',
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(105, 105, 105, 1),
                fontFamily: 'Inter',
                fontSize: 14,
                letterSpacing:
                2 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          const SizedBox(
            width: 10,
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
          const SizedBox(
            width: 10,
          ),
          Text(
            '$progressInt of 4',
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromRGBO(105, 105, 105, 1),
                fontFamily: 'Inter',
                fontSize: 14,
                letterSpacing:
                2 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          const SizedBox(
            width: 10,
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
