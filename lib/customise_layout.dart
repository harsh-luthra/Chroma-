import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/MarkersDataObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomiseLayout extends StatefulWidget {
  const CustomiseLayout({Key? key}) : super(key: key);

  @override
  State<CustomiseLayout> createState() => CustomiseLayoutState();
}

class CustomiseLayoutState extends State<CustomiseLayout> {

  bool movingToNextView = false;

  // create some values
  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.greenColor.toString();
  late SharedPreferences prefs;

  double fPS = 30;

  late Timer timer;
  bool stopRecordingBool = false;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "3";
  bool showBack = true;

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

  MarkersDataObj markersDataObj = MarkersDataObj();

  double brightnessSliderValue = 0.5;

  // Color containerBorderColour = const Color.fromARGB(125, 0, 0, 0);
  // Color containerColour = const Color.fromARGB(125, 0, 0, 0);

  double? fontSize = 15;
  File? PickedImage;
  String? loadedMarker = "1";

  Color markerColor = const Color(0xffffffff);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    print(Duration.microsecondsPerSecond ~/ fPS);
    setState(() {
      cornerMargin = _currentSliderValue / 100;
      //markerSize = _secondSliderValue * (screenWidth! * 0.0025);.
      StartState();
    });
    getCustomImage();
  }

  void getCustomImage() async{
    final pathGot = await getApplicationDocumentsDirectory();
    const fileNameToSave = (AppConstants.customImageName);
    File checkFile = File('${pathGot.path}/$fileNameToSave');
    if(await checkFile.exists()){
      setState(() {
        PickedImage = checkFile;
      });
    }
  }

  void StartState()async{
    brightnessSliderValue = await currentBrightness;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    markerSize = _secondSliderValue * (screenWidth! * 0.0025);
    fontSize = screenWidth! * 0.038;
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
                      markersDataObj.markerTopLeft =
                          !markersDataObj.markerTopLeft;
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
                      markersDataObj.markerTopCenter =
                          !markersDataObj.markerTopCenter;
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
                      markersDataObj.markerTopRight =
                          !markersDataObj.markerTopRight;
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
                      markersDataObj.markerMiddleLeft =
                          !markersDataObj.markerMiddleLeft;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerMiddleLeft),
                ),
              ),

              // MIDDLE CENTER
              Positioned(
                top: screenHeight! * 0.4,
                bottom: screenHeight! * 0.4,
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      markersDataObj.markerCenter =
                          !markersDataObj.markerCenter;
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
                      markersDataObj.markerMiddleRight =
                          !markersDataObj.markerMiddleRight;
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
                      markersDataObj.markerBottomLeft =
                          !markersDataObj.markerBottomLeft;
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
                      markersDataObj.markerBottomCenter =
                          !markersDataObj.markerBottomCenter;
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
                      markersDataObj.markerBottomRight =
                          !markersDataObj.markerBottomRight;
                      HapticFeedback.mediumImpact();
                    });
                  },
                  child: markerWidget(markersDataObj.markerBottomRight),
                ),
              ),

              // Tutorial Text
              Positioned(
                bottom: screenHeight! * 0.56,
                child: Container(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: AppConstants.containerGreyColor,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  alignment: Alignment.center,
                  height: screenHeight! * 0.16,
                  width: screenWidth! * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: screenWidth! * 0.09,
                        height: screenWidth! * 0.09,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          image: DecorationImage(
                            image: AssetImage('assets/images/holdfingericon.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight! * 0.015,
                      ),
                      AutoSizeText(
                        "Hold markers to toggle visibility",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Proxima Nova',
                            fontSize: fontSize!*1.35,
                            fontWeight: FontWeight.w500,
                            height: 1),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      AutoSizeText(
                        "(Low opacity markers wont be visible at launch)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppConstants.whiteTxtColor,
                            fontFamily: 'Proxima Nova',
                            fontSize: fontSize! * 0.97,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            height: 1),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // SLIDERS

              Positioned(
                bottom: screenHeight! * 0.12,
                child: Column(
                  children: [

                    // Marker Margin Slider
                    Container(
                      decoration: BoxDecoration(
                          color: AppConstants.containerGreyColor,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      height: screenHeight! * 0.05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: screenWidth! * 0.04),
                          Text(
                            'Marker Position',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Proxima Nova',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                height: 1),
                          ),
                          SizedBox(
                            width: screenWidth! * 0.6,
                            height: screenHeight! * 0.05,
                            child: Slider(
                              activeColor: AppConstants.sliderActiveColor,
                              inactiveColor: AppConstants.sliderInActiveColor,
                              value: _currentSliderValue,
                              min: 0,
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

                    SizedBox(height: screenHeight! * 0.015,),

                    // Marker Size Slider
                    Container(
                      transformAlignment: Alignment.center,
                      decoration: BoxDecoration(
                        // boxShadow: const [
                        //   BoxShadow(
                        //       color: Color.fromRGBO(0, 0, 0, 0.5),
                        //       offset: Offset(0, 6),
                        //       blurRadius: 4)
                        // ],
                        // gradient: const LinearGradient(
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        //   colors: [
                        //     Color.fromRGBO(127, 127, 127, 1),
                        //     Color.fromRGBO(0, 0, 0, 0.29),
                        //   ],
                        // ),
                          color: AppConstants.containerGreyColor,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      height: screenHeight! * 0.05,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth! * 0.04),
                          Text(
                            'Marker Size',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Proxima Nova',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                height: 1),
                          ),
                          SizedBox(width: screenWidth! * 0.07),
                          SizedBox(
                            width: screenWidth! * 0.6,
                            height: screenHeight! * 0.05,
                            child: Slider(
                              activeColor: AppConstants.sliderActiveColor,
                              inactiveColor: AppConstants.sliderInActiveColor,
                              value: _secondSliderValue,
                              min: 20,
                              max: 60,
                              divisions: 10,
                              label: _secondSliderValue.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  //print(value);
                                  _secondSliderValue = value;
                                  markerSize = _secondSliderValue * (screenWidth! * 0.0025);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight! * 0.015,),

                    // Brightness Slider
                    Container(
                      transformAlignment: Alignment.center,
                      decoration: BoxDecoration(
                        // boxShadow: const [
                        //   BoxShadow(
                        //       color: Color.fromRGBO(0, 0, 0, 0.5),
                        //       offset: Offset(0, 6),
                        //       blurRadius: 4)
                        // ],
                        // gradient: const LinearGradient(
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        //   colors: [
                        //     Color.fromRGBO(127, 127, 127, 1),
                        //     Color.fromRGBO(0, 0, 0, 0.29),
                        //   ],
                        // ),
                          color: AppConstants.containerGreyColor,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      height: screenHeight! * 0.05,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth! * 0.04),
                          Text(
                            'Brightness',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Proxima Nova',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                height: 1),
                          ),
                          SizedBox(width: screenWidth! * 0.07),
                          SizedBox(
                            width: screenWidth! * 0.6,
                            height: screenHeight! * 0.05,
                            child: Slider(
                              activeColor: AppConstants.sliderActiveColor,
                              inactiveColor: AppConstants.sliderInActiveColor,
                              value: brightnessSliderValue,
                              min: 0.1,
                              max: 1.0,
                              divisions: 9,
                              label: (brightnessSliderValue * 100).toInt().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  setBrightness(value);
                                  brightnessSliderValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight! * 0.03,),
                    //brightnessSlider(),
                    progressBarSized(0.75),
                    SizedBox(
                      height: screenHeight! * 0.01,
                    ),
                    bottomBackButton(),
                    // Buttons
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [
                    //     //Reset Button
                    //     gradientButton("Reset",(){
                    //       setState(() {
                    //         HapticFeedback.mediumImpact();
                    //         resetSettings();
                    //       });
                    //     }),
                    //     //Save Button
                    //     SizedBox(width: screenWidth! * 0.02),
                    //     gradientButton("Save",(){
                    //       setState(() {
                    //         HapticFeedback.mediumImpact();
                    //         saveData();
                    //       });
                    //     }),
                    //     //Exit Button
                    //     SizedBox(width: screenWidth! * 0.02),
                    //     gradientButton("Exit",(){
                    //       setState(() {
                    //         HapticFeedback.mediumImpact();
                    //         Navigator.pop(context);
                    //       });
                    //     }),
                    //   ],
                    // ),
                  ],
                ),
              ),

              // // Marker Margin Slider
              // Positioned(
              //   bottom: screenHeight! * 0.365,
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: AppConstants.containerGreyColor,
              //         border: Border.all(
              //           color: Colors.transparent,
              //         ),
              //         borderRadius: const BorderRadius.all(Radius.circular(20))),
              //     height: screenHeight! * 0.05,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         SizedBox(width: screenWidth! * 0.04),
              //         Text(
              //           'Marker Position',
              //           textAlign: TextAlign.left,
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontFamily: 'Proxima Nova',
              //               fontSize: fontSize,
              //               fontWeight: FontWeight.w500,
              //               height: 1),
              //         ),
              //         SizedBox(
              //           width: screenWidth! * 0.6,
              //           height: screenHeight! * 0.05,
              //           child: Slider(
              //             activeColor: AppConstants.sliderActiveColor,
              //             inactiveColor: AppConstants.sliderInActiveColor,
              //             value: _currentSliderValue,
              //             min: 0,
              //             max: 20,
              //             divisions: 20,
              //             label: _currentSliderValue.round().toString(),
              //             onChanged: (double value) {
              //               setState(() {
              //                 //print(value);
              //                 _currentSliderValue = value;
              //                 cornerMargin = _currentSliderValue / 100;
              //               });
              //             },
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Marker Size Slider
              // Positioned(
              //   bottom: screenHeight! * 0.29,
              //   child: Container(
              //     transformAlignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       // boxShadow: const [
              //       //   BoxShadow(
              //       //       color: Color.fromRGBO(0, 0, 0, 0.5),
              //       //       offset: Offset(0, 6),
              //       //       blurRadius: 4)
              //       // ],
              //       // gradient: const LinearGradient(
              //       //   begin: Alignment.topCenter,
              //       //   end: Alignment.bottomCenter,
              //       //   colors: [
              //       //     Color.fromRGBO(127, 127, 127, 1),
              //       //     Color.fromRGBO(0, 0, 0, 0.29),
              //       //   ],
              //       // ),
              //         color: AppConstants.containerGreyColor,
              //         border: Border.all(
              //           color: Colors.transparent,
              //         ),
              //         borderRadius: const BorderRadius.all(Radius.circular(20))),
              //     height: screenHeight! * 0.05,
              //     child: Row(
              //       children: [
              //         SizedBox(width: screenWidth! * 0.04),
              //         Text(
              //           'Marker Size',
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontFamily: 'Proxima Nova',
              //               fontSize: fontSize,
              //               fontWeight: FontWeight.w500,
              //               height: 1),
              //         ),
              //         SizedBox(width: screenWidth! * 0.07),
              //         SizedBox(
              //           width: screenWidth! * 0.6,
              //           height: screenHeight! * 0.05,
              //           child: Slider(
              //             activeColor: AppConstants.sliderActiveColor,
              //             inactiveColor: AppConstants.sliderInActiveColor,
              //             value: _secondSliderValue,
              //             min: 20,
              //             max: 60,
              //             divisions: 10,
              //             label: _secondSliderValue.round().toString(),
              //             onChanged: (double value) {
              //               setState(() {
              //                 //print(value);
              //                 _secondSliderValue = value;
              //                 markerSize = _secondSliderValue * (screenWidth! * 0.0025);
              //               });
              //             },
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Buttons
              // Positioned(
              //   bottom: screenHeight! * 0.21,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       //Reset Button
              //       gradientButton("Reset",(){
              //         setState(() {
              //           HapticFeedback.mediumImpact();
              //           resetSettings();
              //         });
              //       }),
              //       //Save Button
              //       SizedBox(width: screenWidth! * 0.02),
              //       gradientButton("Save",(){
              //         setState(() {
              //           HapticFeedback.mediumImpact();
              //           saveData();
              //         });
              //       }),
              //       //Exit Button
              //       SizedBox(width: screenWidth! * 0.02),
              //       gradientButton("Exit",(){
              //         setState(() {
              //           HapticFeedback.mediumImpact();
              //           Navigator.pop(context);
              //         });
              //       }),
              //     ],
              //   ),
              // ),

            ],
          ),
        ),
      ),
    );
  }

  Widget progressBarSized(double progress) {
    double? progressFullWidth = screenWidth! * 0.42;
    return Stack(children: <Widget>[
      // Full Bar
      Container(
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
                boxShadow: [
                  BoxShadow(
                    offset: Offset(
                      1.0,
                      3.0,
                    ),
                    color: Colors.black12,
                    spreadRadius: 4,
                    blurRadius: 4,
                  )
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(38.84709167480469),
                  topRight: Radius.circular(38.84709167480469),
                  bottomLeft: Radius.circular(38.84709167480469),
                  bottomRight: Radius.circular(38.84709167480469),
                ),
                color: AppConstants.greenAltColor,
              )),
        ]),
      ),
    ]);
  }

  Widget bottomBackButton() {
    double backButtonSize = screenWidth! * 0.1;
    if (showBack) {
      return Column(
        children: [
          Row(
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
                          image: AppConstants.backImg,
                          fit: BoxFit.fitWidth,
                          invertColors: false),
                    )),
              ),
              SizedBox(width: screenWidth! * 0.035),
              SizedBox(
                width: screenWidth! * 0.15,
                child: Text(
                  '$progressInt of 4',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      letterSpacing:
                      2 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              ),
              SizedBox(width: screenWidth! * 0.035),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // To Fix Bug of Not Moving to Main Screen Many times
                      if(movingToNextView == true){
                        return;
                      }
                      movingToNextView = true;
                      HapticFeedback.mediumImpact();
                      saveData();
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: backButtonSize,
                      height: backButtonSize,
                      decoration: const BoxDecoration(
                      image: DecorationImage(
                      image: AppConstants.forwardImg,
                      fit: BoxFit.fitWidth,
                      invertColors: false),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Back',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: fontSize,
                    letterSpacing:
                    2 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              SizedBox(width: screenWidth! * 0.21),
              Text(
                'Next',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: fontSize,
                    letterSpacing:
                    2 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          )
        ],
      );
    } else {
      return Column(
        children: [
          Row(
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
              SizedBox(width: screenWidth! * 0.09),
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
              SizedBox(width: screenWidth! * 0.09),
              Container(
                alignment: Alignment.centerLeft,
                width: backButtonSize,
                height: backButtonSize,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '',
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
              SizedBox(width: screenWidth! * 0.31),
            ],
          )
        ],
      );
    }
  }

  void goBack() async {
    Navigator.pop(context);
    //await FullScreen.exitFullScreen();
  }

  Widget gradientButton(String title, Function() action){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        minimumSize: const Size(12.0, 12.0),
        padding: const EdgeInsets.all(0.0),
      ),
      onPressed: () {
       action();
      },
      child: Ink(
        padding: const EdgeInsets.only(top: 10, left: 15, right: 15,bottom: 10),
        width: screenWidth! * 0.19,
        decoration: const BoxDecoration(
            color: AppConstants.buttonGreyColor,
          // gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     stops: [
          //       0.1,
          //       0.8,
          //       0.9
          //     ],
          //     colors: [
          //       Color.fromRGBO(127, 127, 127, 1),
          //       Color.fromRGBO(127, 127, 127, 1),
          //       Color.fromRGBO(127, 127, 127, 1),
          //     ]),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text (title, textAlign: TextAlign.center, style: TextStyle(
          fontSize: fontSize,
        ),),
      ),
    );
  }

  Widget gradientButtonOld(String title, Function() action){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 4.0,
        minimumSize: const Size(15.0, 15.0),
        padding: const EdgeInsets.all(0.0),
      ),
      onPressed: () {
        action();
      },
      child: Ink(
        padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
        height: 35,
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
                Color.fromRGBO(127, 127, 127, 1),
                Color.fromRGBO(0, 0, 0, 0.29),
                Color.fromRGBO(0, 0, 0, 0.29),
              ]),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Text (title),
      ),
    );
  }

  Widget brightnessSlider() {
    // Brightness Slider
    return Container(
      decoration: BoxDecoration(
          color: AppConstants.containerGreyColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      height: screenHeight! * 0.09,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: screenWidth! * 0.04),
          SizedBox(height: screenHeight! * 0.005),
          Text(
            'Brightness',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Proxima Nova',
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                height: 1),
          ),
          SizedBox(height: screenHeight! * 0.0025),
          SizedBox(
            width: screenWidth! * 0.6,
            height: screenHeight! * 0.05,
            child: Slider(
              activeColor: AppConstants.sliderActiveColor,
              inactiveColor: AppConstants.sliderInActiveColor,
              value: brightnessSliderValue,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: (brightnessSliderValue * 100).toInt().toString(),
              onChanged: (double value) {
                setState(() {
                  setBrightness(value);
                  brightnessSliderValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<double> get currentBrightness async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      print(e);
      throw 'Failed to get current brightness';
    }
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
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

    markersDataObj = MarkersDataObj();

    markersDataObj.markerTopLeft = true;
    markersDataObj.markerTopCenter = true;
    markersDataObj.markerTopRight = true;

    markersDataObj.markerMiddleLeft = true;
    markersDataObj.markerCenter = true;
    markersDataObj.markerMiddleRight = true;

    markersDataObj.markerBottomLeft = true;
    markersDataObj.markerBottomCenter = true;
    markersDataObj.markerBottomRight = true;
  }

  Widget markerWidget(bool isMarkerEnabled) {
    //Color markerColor = enabledMarkerColor;
    double opacity = 1.0;
    if (isMarkerEnabled) {
      //markerColor = enabledMarkerColor;
      opacity = 1.0;
    } else {
      //markerColor = disabledMarkerColor;
      opacity = 0.25;
    }
    if(loadedMarker == "1" || loadedMarker == "2"){
      return Container(
        width: markerSize,
        height: markerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          image: DecorationImage(
            opacity: opacity,
            image: selectedMarker,
            // image: (loadedMarker == "1" || loadedMarker == "2") ? selectedMarker : FileImage(PickedImage!) as ImageProvider,
          ),
        ),
      );
    }else{
      return Container(
        width: markerSize,
        height: markerSize,
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   color: Colors.transparent,
        //   image: DecorationImage(
        //     opacity: 1,
        //     image: selectedMarker,
        //     // image: (loadedMarker == "1" || loadedMarker == "2") ? selectedMarker : FileImage(PickedImage!) as ImageProvider,
        //   ),
        // ),
        child: ColorFiltered(
            colorFilter:
            ColorFilter.mode(markerColor.withOpacity(1.0), BlendMode.srcIn),
            child: Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      opacity: opacity,
                      image: (selectedMarker), fit: BoxFit.fitWidth),
                  // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                ))
        ),
      );
    }
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

    // Load Main Color
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
    loadedMarker = prefs.getString('selectedMarker');
    print("Loaded Marker $loadedMarker");
    if (loadedMarker != null) {
      if (loadedMarker == "1") {
        selectedMarker = AppConstants.plusImg;
      } else if (loadedMarker == "2") {
        selectedMarker = AppConstants.sfCircleImg;
      } else {
        final String? customMarkerString = prefs.getString('customMarker');
        if (customMarkerString != null) {
          selectedMarker = AssetImage(customMarkerString);
        }
        //selectedMarker = AppConstants.sfCircleImg;
      }
    } else {
      selectedMarker = AppConstants.plusImg;
    }
    setState(() {
      selectedMarker = selectedMarker;
    });

    // Load Marker Color
    final String? loadedMarkerColor = prefs.getString('markerColor');
    print("loadedMarker Color $loadedColor");
    if (loadedMarkerColor != null) {
      String valueString = loadedMarkerColor.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      markerColor = Color(value);
      setState(() {
        markerColor = Color(value);
      });
    } else {
      String? valueString = defaultColor?.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString!, radix: 16);
      markerColor = Color(value);
      setState(() {
        markerColor = Color(value);
      });
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
    } else {
      cornerMargin = 0.01;
    }

    // Load Marker Size
    final String? loadedSize = prefs.getString('markerSize');
    print("Loaded Marker Size $loadedSize");
    if (loadedSize != null) {
      _secondSliderValue = double.parse(loadedSize);
    } else {
      _secondSliderValue = 40;
    }

    final String? markerDataobjString = prefs.getString('markerDataobjString');
    if (markerDataobjString != null) {
      print(markerDataobjString.toString());
      Map<String, dynamic> datamap = jsonDecode(markerDataobjString);
      markersDataObj = MarkersDataObj.fromJson(datamap);
    } else {
      markersDataObj = MarkersDataObj();
      print(markerDataobjString.toString());
    }

    setState(() {
      selectedColor = selectedColor;
      selectedMarker = selectedMarker;
      cornerMargin = cornerMargin;
      //markerSize = markerSize;
      _secondSliderValue = _secondSliderValue;
      markerSize = _secondSliderValue * (screenWidth! * 0.0025);
      _currentSliderValue = cornerMargin * 100;
      markersDataObj = markersDataObj;
      setStateOfMarkersFromLoadedData();
    });
  }

  void saveData() async {
    //saveMarkerObjData();
    movingToNextView = true;
    await prefs.setString(
        "markerDataobjString", json.encode(markersDataObj.toJson()));
    await prefs.setString('selectedLayout', "2");
    await prefs.setString('cornerMargin', cornerMargin.toString());
    await prefs.setString('markerSize', _secondSliderValue.toString());
    Future.delayed(const Duration(milliseconds: 250), () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) {
      //       return const MainScreen();
      //     },
      //   ),
      // );
      Navigator.pushNamed(context, '/mainScreen');
      movingToNextView = false;
      // Navigator.popAndPushNamed(context, '/mainScreen');
    });
  }

  void setStateOfMarkersFromLoadedData() {
    if (markersDataObj.markerTopLeft) {
      makerColorTopLeft = Colors.transparent;
    } else {
      makerColorTopLeft = Colors.red;
    }

    if (markersDataObj.markerTopCenter) {
      makerColorTopCenter = Colors.transparent;
    } else {
      makerColorTopCenter = Colors.red;
    }

    if (markersDataObj.markerTopRight) {
      makerColorTopRight = Colors.transparent;
    } else {
      makerColorTopRight = Colors.red;
    }

    if (markersDataObj.markerMiddleLeft) {
      makerColorMiddleLeft = Colors.transparent;
    } else {
      makerColorMiddleLeft = Colors.red;
    }

    if (markersDataObj.markerCenter) {
      makerColorCenter = Colors.transparent;
    } else {
      makerColorCenter = Colors.red;
    }

    if (markersDataObj.markerMiddleRight) {
      makerColorMiddleRight = Colors.transparent;
    } else {
      makerColorMiddleRight = Colors.red;
    }

    if (markersDataObj.markerBottomLeft) {
      makerColorBottomLeft = Colors.transparent;
    } else {
      makerColorBottomLeft = Colors.red;
    }

    if (markersDataObj.markerBottomCenter) {
      makerColorBottomCenter = Colors.transparent;
    } else {
      makerColorBottomCenter = Colors.red;
    }

    if (markersDataObj.markerBottomRight) {
      makerColorBottomRight = Colors.transparent;
    } else {
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
