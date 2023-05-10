import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/Data_List.dart';
import 'package:chroma_plus_flutter/MarkersDataObj.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:neon_circular_timer/neon_circular_painter.dart';
import 'package:neon_circular_timer/neon_circular_timer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

import 'dart:math' as math;

import 'CustomTimerPainterNew.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  // create some values
  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.greenColor.toString();
  late var prefs;
  static const TWO_PI = 3.14 * 2;
  double FPS = 30;

  late Timer timer;
  bool stopRecordingBool = false;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "4";
  bool showBack = true;

  // double _currentSliderValue = 10;
  // double _secondSliderValue = 40;

  Color selectedColor = const Color(0xffffffff);
  AssetImage selectedMarker = AppConstants.plusImg;
  double cornerMargin = 0.01;

  double markerSize = 40;

  List<double>? _accelerometerValues;
  List<List<String>> _accelerometerValues_List = [];
  late String old_accelerometerValues = "";

  List<double>? _gyroscopeValues;
  List<List<String>> _gyroscopeValues_List = [];

  int fingersNowHold = 0;
  Timer holdTimer = Timer(const Duration(milliseconds: 1), () {});
  bool ShowHoldMenu = true;

  double? fontSize = 15;

  double brightnessSliderValue = 0.5;

  MarkersDataObj markersDataObj = new MarkersDataObj();
  bool animating = false;
  File? PickedImage;
  String? loadedMarker = "1";

  late AnimationController controller;
  late AnimationController controller_txt_color;
  late AnimationController controller_txt_opacity;
  late Animation _colorAnim;
  Color txt_color = Colors.grey;

  double _progress = 1.0;

  final CountDownController Count_controller = new CountDownController();
  Color markerColor = const Color(0xffffffff);

  double txt_opacity = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StartState();

    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    controller.addListener(() {
      if(controller.value == 1.0){
        print("Done");
        ShowHoldMenu = !ShowHoldMenu;
        ToggleFullScreen();
        HapticFeedback.mediumImpact();
        controller.reset();
      }
      setState(() {});
    });

     controller_txt_color = AnimationController(duration: Duration(seconds: 2), vsync: this);
     _colorAnim = ColorTween(begin:Colors.white,end: AppConstants.greenColor).animate(controller_txt_color);

     controller_txt_opacity = AnimationController(duration: Duration(seconds: 1), vsync: this);

    _colorAnim.addListener((){
      if(controller_txt_color.value > 0){
        controller_txt_opacity.forward();
      }

      if(controller_txt_color.value == 1.0){
         controller_txt_color.reset();
         controller_txt_opacity.reset();
      }

      setState(() {
        txt_color = _colorAnim.value;
        if(controller_txt_color.value == 0){
          controller_txt_opacity.reset();
        }
      });
    });

    // loadData();
    // listenAllSensors();
    // brightnessSliderValue = currentBrightness as double;
    // //print(Duration.microsecondsPerSecond ~/ FPS);
    // setState(() {
    //   showingThreeFingersMenu = true;
    // });
  }

  void StartState() async {
    getCustomImage();
    loadData();
    listenAllSensors();
    brightnessSliderValue = await currentBrightness;
    //print(Duration.microsecondsPerSecond ~/ FPS);
    setState(() {
      print("B: $brightnessSliderValue");
      ShowHoldMenu = true;
    });
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    fontSize = screenWidth! * 0.038;
    double cornerSpace = screenWidth! * cornerMargin;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: selectedColor,
        body: GestureDetector(
          // onScaleStart: (de) {
          //   print(de.pointerCount);
          //   fingersNowHold = de.pointerCount;
          //   onThreeHold(de.pointerCount);
          // },
          // onScaleUpdate: (de) {
          //   print(de.pointerCount);
          //   fingersNowHold = de.pointerCount;
          //   if (de.pointerCount != 3) {
          //     cancelHoldTimer();
          //   }
          // },
          onTapDown: (dw){
            setState(() {
              controller.forward();
              controller_txt_color.forward();
            });
            //Count_controller.start();
          },
          onTapUp: (dw){
              // Count_controller.restart();
              // Count_controller.pause();
            if (controller.status == AnimationStatus.forward) {
              setState(() {
                controller.reverse();
                controller_txt_color.reverse();
              });
            }
          },
          // onScaleEnd: (de){
          //   // print(de.pointerCount);
          //   // fingersNowHold = de.pointerCount;
          //   // if (de.pointerCount != 3) {
          //   //   cancelHoldTimer();
          //   // }
          // },
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
                    child: markerWidget(markersDataObj.markerTopLeft),
                  ),

                  // TOP CENTER
                  Positioned(
                    top: cornerSpace,
                    child: markerWidget(markersDataObj.markerTopCenter),
                  ),

                  // TOP Right
                  Positioned(
                    top: cornerSpace,
                    right: cornerSpace,
                    child: markerWidget(markersDataObj.markerTopRight),
                  ),

                  // MIDDLE LEFT
                  Positioned(
                    left: cornerSpace,
                    child: markerWidget(markersDataObj.markerMiddleLeft),
                  ),

                  // MIDDLE CENTER
                  Positioned(
                    top: screenHeight! * 0.4,
                    bottom: screenHeight! * 0.4,
                    child: markerWidget(markersDataObj.markerCenter),
                  ),

                  // MIDDLE RIGHT
                  Positioned(
                    right: cornerSpace,
                    child: markerWidget(markersDataObj.markerMiddleRight),
                  ),

                  // BOTTOM Left
                  Positioned(
                    bottom: cornerSpace,
                    left: cornerSpace,
                    child: markerWidget(markersDataObj.markerBottomLeft),
                  ),

                  // BOTTOM CENTER
                  Positioned(
                    bottom: cornerSpace,
                    child: markerWidget(markersDataObj.markerBottomCenter),
                  ),

                  // BOTTOM Right
                  Positioned(
                    bottom: cornerSpace,
                    right: cornerSpace,
                    child: markerWidget(markersDataObj.markerBottomRight),
                  ),

                  //fingersHoldMenu(),
                  newHoldMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget markerWidget(bool isMarkerEnabled) {
    if (isMarkerEnabled) {
      if(loadedMarker == "1" || loadedMarker == "2"){
        return Container(
          width: markerSize,
          height: markerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            image: DecorationImage(
              opacity: 1,
              image: selectedMarker,
              // image: (loadedMarker == "1" || loadedMarker == "2") ? selectedMarker : FileImage(PickedImage!) as ImageProvider,
            ),
          ),
        );
      }else{
        return SizedBox(
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
                        image: (selectedMarker), fit: BoxFit.fitWidth),
                    // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                  ))
          ),
        );
      }
    } else {
      return Container();
    }
  }

  Widget newHoldMenu() {
    if (ShowHoldMenu) {
      return Stack(alignment: Alignment.center, children: [
        Container(
          margin: EdgeInsets.only(left: (screenWidth!*0.065), right: (screenWidth!*0.065), top: (screenHeight!*0.3), bottom: screenHeight!*0.155),
          decoration: BoxDecoration(
              color: const Color.fromARGB(190, 0, 0, 0),
              border: Border.all(
                color: const Color.fromARGB(190, 0, 0, 0),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
        ),
        Positioned(
          top: screenHeight! * 0.42,
          child: SampleTest(),
          // child: CircularPercentIndicator(
          //       radius: screenWidth!*0.175,
          //       backgroundColor: Colors.white,
          //       progressColor: AppConstants.greenAltColor,
          //       percent: controller.value,
          //       startAngle: 90,
          //       center: Container(
          //         width: screenWidth!*0.325,
          //         height: screenWidth!*0.325,
          //         decoration: const BoxDecoration(
          //             shape: BoxShape.circle, color: Color.fromARGB(125, 0, 0, 0),),
          //         child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             mainAxisSize: MainAxisSize.max,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: const [
          //               Text(
          //                 "HOLD",
          //                 style: TextStyle(
          //                     fontSize: 30,
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold),
          //               ),
          //               Text(
          //                 "TO GET STARTED",
          //                 style: TextStyle(
          //                     fontSize: 10,
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold),
          //               ),
          //             ]),
          //       ),
          // ),
        ),
        Positioned(
          top: screenHeight! * 0.35,
          // child: Text(
          //   "HOLD TO COME BACK",
          //   style: TextStyle(
          //       fontSize: fontSize,
          //       color: txt_color,
          //       fontWeight: FontWeight.bold),
          // ),
          child: txt_come_back(),
        ),
        Positioned(
          bottom: screenHeight! * 0.19,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // SizedBox(
              //   height: screenHeight! * 0.025,
              // ),
              progressBarSized(1),
              SizedBox(
                height: screenHeight! * 0.01,
              ),
              bottomBackButton(),
            ],
          ),
        ),
      ]);
    } else {
      return Container();
    }
  }

  Widget txt_come_back(){
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      child: Text(
        "HOLD TO COME BACK",
        style: TextStyle(
            fontSize: fontSize,
            color: txt_color.withOpacity(controller_txt_opacity.value),
            //color: txt_color,
            fontWeight: FontWeight.bold),
      ),
    );
    // if(controller_txt_color.value > 0){
    //   return AnimatedContainer(
    //     duration: Duration(seconds: 1),
    //     child: Text(
    //       "HOLD TO COME BACK",
    //       style: TextStyle(
    //           fontSize: fontSize,
    //           // color: txt_color.withOpacity(controller_txt_opacity.value),
    //           color: txt_color,
    //           fontWeight: FontWeight.bold),
    //     ),
    //   );
    // }else{
    //   return Container();
    // }
  }

  // WORKING GLOW CIRCLE PROGRESS BAR
  Widget SampleTest(){
    //AnimationController? _controller;
    Animation<double>? countDownAnimation;
      return Center(
        child: Container(
          width: screenWidth!*0.35,
          height: screenWidth!*0.35,
          child: AnimatedBuilder(
              animation: controller!,
              builder: (context, child) {
                return Align(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CustomTimerPainterNew(
                                neumorphicEffect: true,
                                backgroundColor: Color.fromARGB(0, 100, 100, 100),
                                animation: countDownAnimation ?? controller,
                                innerFillColor: Colors.transparent,
                                innerFillGradient: const LinearGradient(colors: [
                                  AppConstants.greenAltColor,
                                  AppConstants.greenAltColor
                                ]),
                                neonColor: Colors.red,
                                neonGradient: const LinearGradient(colors: [
                                  AppConstants.greenAltColor,
                                  AppConstants.greenAltColor
                                ]),
                                innerStrokeWidth: 10,
                                outerStrokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                outerStrokeColor: Colors.white70,
                                outerStrokeGradient: const LinearGradient(colors: [
                                  AppConstants.greenAltColor,
                                  AppConstants.greenAltColor
                                ]),
                                neon: 10),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.center,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "HOLD",
                                  style: TextStyle(
                                      letterSpacing: 5,
                                      fontSize: fontSize!*2,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "TO GET STARTED",
                                  style: TextStyle(
                                      letterSpacing: 2,
                                      fontSize: fontSize!/1.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                        ),
                        Container(),
                      ],
                    ),
                  ),
                );
              }),
        ),
      );
  }

  Widget CircularNeonProgress(){
    return Stack(
      alignment: Alignment.center,
      children: [
        NeonCircularTimer(
          width: screenWidth!*0.35,
          duration: 2,
          controller : Count_controller,
          isTimerTextShown: false,
          neumorphicEffect: false,
          autoStart: false,
          innerFillGradient: LinearGradient(colors: [
            AppConstants.greenAltColor,
            AppConstants.greenAltColor
          ]),
          neonGradient: LinearGradient(colors: [
            AppConstants.greenAltColor,
            AppConstants.greenAltColor
          ]),
          // innerFillGradient: LinearGradient(colors: [
          //   Colors.greenAccent.shade200,
          //   Colors.blueAccent.shade400
          // ]),
          // neonGradient: LinearGradient(colors: [
          //   Colors.greenAccent.shade200,
          //   Colors.blueAccent.shade400
          // ]),
        ),
      ],
    );
  }

  Widget CircleTest() {
    final size = screenWidth!*0.325;
      return Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return SweepGradient(
                  startAngle: 0.0,
                  endAngle: TWO_PI,
                  stops: [controller.value, controller.value],
                  // 0.0 , 0.5 , 0.5 , 1.0
                  center: Alignment.center,
                  colors: [Colors.green, Colors.white]).createShader(rect);
            },
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
            ),
          ),
          Center(
            child: Container(
              width: size - 10,
              height: size - 10,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "HOLD",
                      style: TextStyle(
                          fontSize: fontSize!*2,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "TO GET STARTED",
                      style: TextStyle(
                          fontSize: (fontSize!/1.5),
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),
          ),
          SizedBox(height: 10,),
        ],
      );
  }

  Widget fingersHoldMenu() {
    if (ShowHoldMenu) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: const Color.fromARGB(190, 0, 0, 0),
          ),
          Positioned(
            top: screenHeight! * 0.15,
            child: Container(
              width: screenWidth! * 0.125,
              height: screenWidth! * 0.125,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/images/threeFingersImg.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight! * 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Hold for 3 Seconds",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
                Text(
                  "to get started\nand to come back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                      height: 1.2),
                ),
                SizedBox(
                  height: screenHeight! * 0.245,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight! * 0.31,
            child: brightnessSlider(),
          ),
          Positioned(
            bottom: screenHeight! * 0.17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                progressBarSized(1),
                SizedBox(
                  height: screenHeight! * 0.01,
                ),
                bottomBackButton(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget Gyroscope() {
    return Column(
      children: [
         Text(
          "Gyroscope data",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1),
        ),
        SizedBox(height: screenHeight! * 0.0125),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                print("Pressed Record Button");
              },
              child: buttonImg(
                  "Record", AppConstants.startRecordImg, screenWidth! * 0.2),
            ),
            SizedBox(width: screenWidth! * 0.06),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                print("Pressed Stop Button");
              },
              child: buttonImg(
                  "Stop", AppConstants.stopRecordImg, screenWidth! * 0.2),
            ),
          ],
        ),
        SizedBox(height: screenHeight! * 0.025),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                print("Pressed All Button");
                All_Data_List();
              },
              child: buttonImg(
                  "All", AppConstants.folderImg, screenWidth! * 0.075),
            ),
            SizedBox(
              width: screenWidth! * 0.17,
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                print("Pressed Export Button");
              },
              child: buttonImg(
                  "Export", AppConstants.exportImg, screenWidth! * 0.075),
            ),
          ],
        ),
        SizedBox(
          height: screenHeight! * 0.025,
        ),
      ],
    );
  }

  void All_Data_List() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Data_List();
        },
      ),
    );
  }

  void goBack() async {
    Navigator.pop(context);
    await FullScreen.exitFullScreen();
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return await FullScreen.exitFullScreen().then((value) {
      return false;
    });
  }

  Widget buttonImg(String title, AssetImage assetImage, double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: assetImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight! * 0.01,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppConstants.txtColor1,
              fontFamily: 'Inter',
              fontSize: fontSize!/2,
              fontWeight: FontWeight.w400,
              height: 1),
        ),
      ],
    );
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
                color: AppConstants.greenAltColor,
              )),
        ]),
      ),
    ]);
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
                      color: const Color.fromRGBO(105, 105, 105, 1),
                      fontFamily: 'Inter',
                      fontSize: fontSize,
                      letterSpacing:
                          2 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              ),
              SizedBox(width: screenWidth! * 0.035),
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
                'Back',
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

  void onThreeHold(int fingersCount) {
    if (fingersCount == 3) {
      print("3 FINGERS DETECTED");
      startHoldTimer();
    }else{
    }
  }

  // Starts Timer for 3 Seconds 3 Fingers Hold Action
  startHoldTimer() {
    if (holdTimer.isActive) {
      return;
    }
    holdTimer = Timer(const Duration(milliseconds: AppConstants.holdTime), () {
      if (fingersNowHold == 3) {
        HapticFeedback.mediumImpact();
        print("3 FINGERS ACTION COMPLETED");
        setState(() {
          ShowHoldMenu = !ShowHoldMenu;
          // if(showingThreeFingersMenu){
          //   animating = false;
          // }
          ToggleFullScreen();
        });
      } else {
        print("NOT 3 FINGERS ACTION CANCELED");
      }
    });
  }

  void ToggleFullScreen() async {
    if (ShowHoldMenu == false) {
      await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    } else {
      await FullScreen.exitFullScreen();
    }
  }

  // Cancel Timer for 3 Seconds 3 Fingers Hold Action
  cancelHoldTimer() {
    if (holdTimer.isActive) {
      holdTimer.cancel();
      // setState(() {
      //   animating = false;
      // });
    }
  }

  // Starts Recording of Sensors DATA to List
  startRecording() {
    timer = Timer.periodic(
        Duration(microseconds: Duration.microsecondsPerSecond ~/ FPS), (timer) {
      if (stopRecordingBool) {
        stopRecording();
      }
      if (!stopRecordingBool) {
        int timeStamp = DateTime.now().microsecondsSinceEpoch;
        print("$timeStamp : $_accelerometerValues");

        // Only When Changed Values
        /*if(old_accelerometerValues != _accelerometerValues.toString()){
          List<String> accelerometerValue = [timeStamp.toString(),_accelerometerValues.toString()];
          _accelerometerValues_List.add(accelerometerValue);
        }
        old_accelerometerValues = _accelerometerValues.toString();*/

        //All the Data
        List<String> accelerometerValue = [
          timeStamp.toString(),
          _accelerometerValues.toString()
        ];
        _accelerometerValues_List.add(accelerometerValue);

        List<String> gyroscopeValue = [
          timeStamp.toString(),
          _gyroscopeValues.toString()
        ];
        _gyroscopeValues_List.add(gyroscopeValue);
      }
    });
  }

  // Stops Recording of Sensors DATA
  stopRecording() {
    timer.cancel();
    _dialogBuilder(context);
    // List<String> header = [];
    // header.add('TimeStamp.');
    // header.add('AccelerometerValues');
    // exportCSV.myCSV(header, _accelerometerValues_List);
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

  void listenAllSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      //print(event);
      _accelerometerValues = <double>[event.x, event.y, event.z];
    });
    gyroscopeEvents.listen((GyroscopeEvent event) {
      //print(event);
      _gyroscopeValues = <double>[event.x, event.y, event.z];
    });
    /* // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
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
    });*/
  }

  void TestCsv() {
    List<String> header = [];
    header.add('No.');
    header.add('User Name');
    header.add('Mobile');
    header.add('ID Number');
    List<List<String>> listOfLists =
        []; //Outter List which contains the data List
    List<String> data1 = [
      '1',
      'Bilal Saeed',
      '1374934',
      '912839812'
    ]; //Inner list which contains Data i.e Row
    List<String> data2 = [
      '2',
      'Ahmar',
      '21341234',
      '192834821'
    ]; //Inner list which contains Data i.e Row
    listOfLists.add(data1);
    listOfLists.add(data2);
    exportCSV.myCSV(header, listOfLists);
  }

  void TestCsv_new() {
    List<List<String>> data = [
      ["No.", "Name", "Roll No."],
      ["1", "54212341212", "5wew42121212"],
      ["2", "5421234r1212", "54yfd2121212"],
      ["3", "54212341212", "54gss2121212"]
    ];
    String csvData = const ListToCsvConverter().convert(data);
    print(csvData);
  }

  void loadData() async {
    prefs = await SharedPreferences.getInstance();

    // Load Main Color
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

    // Load Layout
    final String? loadedLayout = prefs.getString('selectedLayout');
    print("Loaded Layout $loadedMarker");
    if (loadedLayout != null) {
      if (loadedLayout == "1") {
        loadDefaultLayout();
      } else {
        loadCustomLayout();
      }
    } else {
      loadDefaultLayout();
    }

    setState(() {
      selectedColor = selectedColor;
      selectedMarker = selectedMarker;
      cornerMargin = cornerMargin;
      markerSize = markerSize;
      markersDataObj = markersDataObj;
    });
  }

  void loadCustomLayout() {
    // Load Custom Layout
    // Load cornerMargin
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
      markerSize = double.parse(loadedSize) * (screenWidth! * 0.0025);
    } else {
      markerSize = 40;
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
  }

  void loadDefaultLayout() {
    cornerMargin = 0.01;
    markerSize = 40;
    markersDataObj = new MarkersDataObj();
  }
}

class GradientArcPainter extends CustomPainter {
  const GradientArcPainter({
    required this.circleSize,
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.width,
  })  : assert(progress != null),
        assert(startColor != null),
        assert(endColor != null),
        assert(width != null),
        super();

  final double circleSize;
  final double progress;
  final Color startColor;
  final Color endColor;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = new SweepGradient(
      startAngle: 3 * math.pi / 2,
      endAngle: 7 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: [startColor, endColor],
    );

    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.butt  // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = circleSize;
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
