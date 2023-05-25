import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/customise_layout.dart';
import 'package:chroma_plus_flutter/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:fullscreen/fullscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fullscreen.dart';

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final Color _sdColor;

  _SliderIndicatorPainter(this.position,this._sdColor);

  @override
  void paint(Canvas canvas, Size size) {
    //canvas.drawCircle(Offset(position, size.height / 2), 12, Paint()..color = Colors.grey);
    canvas.drawCircle(Offset(position, size.height / 2), 12, Paint()..color = _sdColor);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

class SelectColor extends StatefulWidget {
  double width = 200.0;

  SelectColor({super.key});

  @override
  State<SelectColor> createState() => SelectColorState();
}

class SelectColorState extends State<SelectColor> {
  File? pickedImage;

  bool movingToNextView = false;

  double? screenWidth;
  double? screenHeight;
  late final String? defaultColor = AppConstants.redColor.toString();
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

  ///////////////////////////////////////////////////////////////////////////////////////
  final List<Color> _colors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 128, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 128, 255, 0),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 128),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 0, 128, 255),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 127, 0, 255),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 0, 127),
    const Color.fromARGB(255, 128, 128, 128),
    const Color.fromARGB(255, 0, 0, 0),
  ];
  double _colorSliderPosition = 100;
  late double _shadeSliderPosition;
  late Color _currentColor;
  late Color _shadedColor;

  AssetImage customMarkerImage = AppConstants.markerPlus;

  @override
  void initState() {
    super.initState();
    exitFullScreen();
    loadData();
    getCustomImage();
  }

  void debugPrint(msg){
    if (kDebugMode) {
      print(msg);
    }
  }

  @override
  void didChangeDependencies() {
    setColorSelectorData();
    setState(() {
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadeSliderPosition = widget.width / 2; //center the shader selector
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
    super.didChangeDependencies();
  }

  void getCustomImage() async {
    final pathGot = await getApplicationDocumentsDirectory();
    const fileNameToSave = (AppConstants.customImageName);
    File checkFile = File('${pathGot.path}/$fileNameToSave');
    if (await checkFile.exists()) {
      setState(() {
        pickedImage = checkFile;
      });
    }
  }

  void setColorSelectorData() {
    widget.width = MediaQuery.of(context).size.width / 2;
    _currentColor = _calculateSelectedColor(_colorSliderPosition);
    _shadeSliderPosition = widget.width / 2; //center the shader selector
    _shadedColor = _calculateShadedColor(_shadeSliderPosition);
  }

  _colorChangeHandler(double position) {
    //handle out of bounds positions
    if (position > widget.width) {
      position = widget.width;
    }
    if (position < 0) {
      position = 0;
    }
    debugPrint("New pos: $position");
    prefrences.setDouble('colorSliderPosition', position);
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    });
  }

  _shadeChangeHandler(double position) {
    //handle out of bounds gestures
    if (position > widget.width) position = widget.width;
    if (position < 0) position = 0;
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      debugPrint(
          "r: ${_shadedColor.red}, g: ${_shadedColor.green}, b: ${_shadedColor.blue}");
    });
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / widget.width;
    if (ratio > 0.5) {
      //Calculate new color (values converge to 255 to make the color lighter)
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      //Calculate new color (values converge to 0 to make the color darker)
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      //return the base color
      return _currentColor;
    }
  }

  Color _calculateSelectedColor(double position) {
    //determine color
    // double positionInColorArray = (position / widget.width * (_colors.length - 1));
    double positionInColorArray = (position / 200.0 * (_colors.length - 1));
    debugPrint(positionInColorArray);
    int index = positionInColorArray.truncate();
    debugPrint(index);
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  @override
  Widget build(BuildContext context) {
    //listenAllSensors();
    // RepeatTest();
    //SetColorSelectorData();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    fontSize = screenWidth! * 0.04;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConstants.bgColor,
        body: Container(
          decoration: const BoxDecoration(
            color: AppConstants.bgColor,
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
                      color: AppConstants.txtColor1,
                      fontFamily: 'Inter',
                      fontSize: fontSize! * 2,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
                Text(
                  'by Scissor Films',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: AppConstants.txtColor1,
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
                      color: AppConstants.txtColor1,
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

  void repeatTest() {
    final periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        printConsole(DateTime.now().millisecondsSinceEpoch);
        // Update user about remaining time
      },
    );
    periodicTimer.cancel();
  }

  void printConsole(msg) {
    if (kDebugMode) {
      debugPrint(msg);
    }
  }

  void stopRecord() {}

  void listenAllSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      printConsole(event);
    });
    // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      printConsole(event);
    });
    // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]
    gyroscopeEvents.listen((GyroscopeEvent event) {
      printConsole(event);
    });
    // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
    magnetometerEvents.listen((MagnetometerEvent event) {
      printConsole(event);
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
      height: screenHeight! * 0.28,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              colorPaletteBox(AppConstants.greenColor, "Green"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              colorPaletteBox(AppConstants.blueColor, "Blue"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              colorPaletteBox(AppConstants.blueColor, "Custom"),
            ],
          ),
          // SizedBox(
          //   height: screenHeight! * 0.0175,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     colorPaletteBox(AppConstants.black_clr, "Black"),
          //     SizedBox(
          //       width: screenWidth! * 0.03,
          //     ),
          //     colorPaletteBox(currentColor, "Custom"),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget markerPickerGroup() {
    return SizedBox(
      width: screenWidth,
      height: screenHeight! * 0.28,
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
              markerPaletteBox(AppConstants.sfCircleImg, "Circle"),
              SizedBox(
                width: screenWidth! * 0.03,
              ),
              markerPaletteBox(customMarkerImage, "Custom"),
            ],
          ),
          // SizedBox(height: (screenHeight! * 0.09) + 10 + 10)
          SizedBox(height: screenHeight! * 0.05),
          colorSelectorSlider(),
          // Stack(
          //   alignment: Alignment.center,
          //   children: <Widget>[
          //     Container(
          //       width: screenHeight! * 0.07,
          //       height: screenHeight! * 0.07,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(15),
          //           topRight: Radius.circular(15),
          //           bottomLeft: Radius.circular(15),
          //           bottomRight: Radius.circular(15),
          //         ),
          //         //color: AppConstants.altColor,
          //         color: selectedColor,
          //       ),
          //     ),
          //      Container(
          //       width: (screenHeight! * 0.07) * 0.5,
          //       height: (screenHeight! * 0.07) * 0.5,
          //        child: ColorFiltered(
          //          colorFilter:
          //          ColorFilter.mode(_shadedColor.withOpacity(1.0), BlendMode.srcIn),
          //          child: Container(
          //              width: 39,
          //              height: 39,
          //              decoration: BoxDecoration(
          //                image: DecorationImage(
          //                    image: (AppConstants.plusImg), fit: BoxFit.fitWidth),
          //                // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
          //              ))
          //        ),
          //      ),
          //   ],
          // ),
          //colorShadeSlider(),
        ],
      ),
    );
  }

  Widget colorSelectorSlider() {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (DragStartDetails details) {
          debugPrint("_-------------------------STARTED DRAG");
          _colorChangeHandler(details.localPosition.dx);
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _colorChangeHandler(details.localPosition.dx);
        },
        onTapDown: (TapDownDetails details) {
          _colorChangeHandler(details.localPosition.dx);
        },
        //This outside padding makes it much easier to grab the   slider because the gesture detector has
        // the extra padding to recognize gestures inside of
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            width: widget.width,
            height: screenHeight!*0.0175,
            //height: 10,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: _colors),
            ),
            child: CustomPaint(
              painter: _SliderIndicatorPainter(_colorSliderPosition,_shadedColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget colorShadeSlider() {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (DragStartDetails details) {
          debugPrint("_-------------------------STARTED DRAG");
          _shadeChangeHandler(details.localPosition.dx);
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _shadeChangeHandler(details.localPosition.dx);
        },
        onTapDown: (TapDownDetails details) {
          _shadeChangeHandler(details.localPosition.dx);
        },
        //This outside padding makes it much easier to grab the slider because the gesture detector has
        // the extra padding to recognize gestures inside of
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            width: widget.width,
            height: 15,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                  colors: [Colors.black, _currentColor, Colors.white]),
            ),
            child: CustomPaint(
              painter: _SliderIndicatorPainter(_shadeSliderPosition,_shadedColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget layoutPickerGroup() {
    return SizedBox(
      width: screenWidth,
      height: screenHeight! * 0.28,
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
              layoutPaletteBox(AppConstants.sfCircleImg, "Custom"),
            ],
          ),
        ],
      ),
    );
  }

  void loadData() async {
    prefrences = await SharedPreferences.getInstance();
    final String? customMarkerString = prefrences.getString('customMarker');
    final double? colorSliderValue = prefrences.getDouble('colorSliderPosition');
    if (colorSliderValue != null) {
      _colorSliderPosition = colorSliderValue;
      _colorChangeHandler(_colorSliderPosition);
    }
    if (customMarkerString != null) {
      customMarkerImage = AssetImage(customMarkerString);
    }
    final String? customColor = prefrences.getString('customColor');
    printConsole("Loaded Color $customColor");
    if (customColor != null) {
      String valueString = customColor.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      currentColor = Color(value);
      printConsole("Current Color $currentColor");
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

  // SELECT COLOR FUNCTION
  void selectColorView() async {
    selectTitle = "Background Color";
    progressInt = "1";
    progressSize = 0.25;
    showBack = false;
  }

  // SELECT MARKER FUNCTION
  void selectMarkerView() async {
    selectTitle = "Select Marker";
    selectedLayout = 2; // TO make it Select Cusotm Layout
    progressInt = "2";
    progressSize = 0.5;
    showBack = true;
    printConsole("Saved Color $selectedColor");
    await prefrences.setString('selectedColor', selectedColor.toString());
    setState(() {
      //_shadedColor = selectedColor;
    });
  }

  // SELECT LAYOUT FUNCTION
  void selectLayout() async {
    movingToNextView = true;
    //selectTitle = "Select Layout";
    //progressInt = "3";
    //progressSize = 0.75;
    showBack = true;
    printConsole("Saved Marker $selectedMarker");
    await prefrences.setString('selectedMarker', selectedMarker.toString());
    await prefrences.setString('markerColor', _shadedColor.toString());
    await prefrences.setString('selectedColor', selectedColor.toString());
    setState(() {
      goToMain();
      //selectedColor = _shadedColor;
      //pickerColor = _shadedColor;
    });
  }

  void exitFullScreen() async {
    await FullScreen.exitFullScreen();
  }

  void goToMain() async {
    await prefrences.setString('selectedLayout', selectedLayout.toString());
    printConsole("Saved Layout $selectedLayout");
    Future.delayed(const Duration(milliseconds: 250), () {
      if (selectedLayout == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const MainScreen();
            },
          ),
        );
      } else if (selectedLayout == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const CustomiseLayout();
            },
          ),
        );
        movingToNextView = false;
        print("MOVED TO CUSTOMISE LAYOUT");
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
          title: Text(
            'Pick a color',
            style: TextStyle(fontSize: fontSize),
          ),
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
              child: Text(
                'Done',
                style: TextStyle(
                    color: AppConstants.buttonTxtColor,
                    fontFamily: 'Inter',
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
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
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppConstants.buttonTxtColor,
                    fontFamily: 'Inter',
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
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
                  color: AppConstants.altColor,
                ),
              ),
              title != "Custom"
                  ? Container(
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
                    )
                  : Container(
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
                        image: const DecorationImage(
                            image: AppConstants.colorCircleImg,
                            fit: BoxFit.fitWidth),
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
                decoration: TextDecoration.none,
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

  Widget markerPaletteBoxWithFile(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    double? markerSize =
        title == "Cross" ? screenHeight! * 0.045 : screenHeight! * 0.045;
    markerSize =
        title == "Circle" ? screenHeight! * 0.0625 : screenHeight! * 0.045;
    // if(title == "Custom"){
    //   showImage = PickedImage == null ? showImage : PickedImage as AssetImage;
    // }
    //double? innerCircleSize = outerCircleSize * 0.34;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (title == "Cross") {
          setState(() {
            selectedMarker = 1;
            selectLayout();
          });
        } else if (title == "Circle") {
          setState(() {
            selectedMarker = 2;
            selectLayout();
          });
        } else if (title == "Custom") {
          setState(() {
            if (pickedImage == null) {
              showDialogCustomMarkers();
              //pickMarkerFromDevice();
            } else {
              selectedMarker = 3; // Need to Change to 3
              selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
              //pickMarkerFromDevice();
            }
          });
        }
      },
      // onLongPress: (){
      //   if (title == "Custom") {
      //     setState(() {
      //     selectedMarker = 2; // Need to Change to 3
      //     // selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
      //     pickMarkerFromDevice();
      //     });
      //   }
      // },
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
                    color: AppConstants.altColor,
                  ),
                ),
              (pickedImage == null || title != "Custom")
                  ? Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: (showImage), fit: BoxFit.fitWidth),
                        // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                      ))
                  : Image.file(
                      width: markerSize,
                      height: markerSize,
                      pickedImage!,
                      fit: BoxFit.cover,
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

  Widget markerPaletteBox(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    double? markerSize = screenHeight! * 0.045;
    if(title == "Cross"){
      markerSize = screenHeight! * 0.045;
    }else if( title == "Circle"){
      markerSize = screenHeight! * 0.0625;
    }else{
      markerSize = screenHeight! * 0.0625;
    }
    return GestureDetector(
      onTap: () {
        if(movingToNextView == true){
          return;
        }
        HapticFeedback.mediumImpact();
        if (title == "Cross") {
          setState(() {
            selectedMarker = 1;
            selectLayout();
          });
        } else if (title == "Circle") {
          setState(() {
            selectedMarker = 2;
            selectLayout();
          });
        } else if (title == "Custom") {
          setState(() {
            selectedMarker = 3;
            // Added here to fix initial empty marker which was default to PLus Marker now What is selected on first app start is there
            prefrences.setString('customMarker', customMarkerImage.assetName);
            selectLayout();
              //ShowDialogCustomMarkers();
          });
        }
      },
      onLongPress: (){
        if (title == "Custom") {
          setState(() {
              showDialogCustomMarkers();
          });
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // title == "Custom" ? Container(
              //   width: outerCircleSize,
              //   height: outerCircleSize,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(outerCircleCorner),
              //       topRight: Radius.circular(outerCircleCorner),
              //       bottomLeft: Radius.circular(outerCircleCorner),
              //       bottomRight: Radius.circular(outerCircleCorner),
              //     ),
              //     color: AppConstants.whiteTxtColor,
              //   ),
              // ) :
              // Container(),
              Container(
                // width: outerCircleSize*0.95,
                // height: outerCircleSize*0.95,
                width: outerCircleSize,
                height: outerCircleSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(outerCircleCorner),
                    topRight: Radius.circular(outerCircleCorner),
                    bottomLeft: Radius.circular(outerCircleCorner),
                    bottomRight: Radius.circular(outerCircleCorner),
                  ),
                  color: AppConstants.altColor,
                ),
              ),
              title != "Custom" ?
              Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: (showImage), fit: BoxFit.fitWidth),
                    // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                  )) :
                  SizedBox(
                  width: markerSize,
                  height: markerSize,
                    child: ColorFiltered(
                        colorFilter:
                        ColorFilter.mode(_shadedColor.withOpacity(1.0), BlendMode.srcIn),
                        child: Container(
                            width: 39,
                            height: 39,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: (showImage), fit: BoxFit.fitWidth),
                              // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                            ))
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

  Widget customMarkersPaletteBox(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    double? markerSize = screenHeight! * 0.06;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          customMarkerImage = showImage;
        });
        debugPrint(customMarkerImage.assetName);
        prefrences.setString('customMarker', customMarkerImage.assetName);
        Navigator.of(context).pop();
        // if (title == "Cross") {
        //   setState(() {
        //     selectedMarker = 1;
        //     selectLayout();
        //   });
        // } else if (title == "Circle") {
        //   setState(() {
        //     selectedMarker = 2;
        //     selectLayout();
        //   });
        // } else if (title == "Custom") {
        //   setState(() {
        //     if (PickedImage == null) {
        //       ShowDialogCustomMarkers();
        //       //pickMarkerFromDevice();
        //     } else {
        //       selectedMarker = 3; // Need to Change to 3
        //       selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
        //       //pickMarkerFromDevice();
        //     }
        //   });
        // }
      },
      // onLongPress: (){
      //   if (title == "Custom") {
      //     setState(() {
      //     selectedMarker = 2; // Need to Change to 3
      //     // selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
      //     pickMarkerFromDevice();
      //     });
      //   }
      // },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: outerCircleSize,
                height: outerCircleSize,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(outerCircleCorner),
                    topRight: Radius.circular(outerCircleCorner),
                    bottomLeft: Radius.circular(outerCircleCorner),
                    bottomRight: Radius.circular(outerCircleCorner),
                  ),
                  color: AppConstants.altColor,
                ),
              ),
              Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: (showImage), fit: BoxFit.fitWidth),
                    // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                  ),
                  // child: ColorFiltered(
                  //        colorFilter:
                  //        ColorFilter.mode(_shadedColor.withOpacity(1.0), BlendMode.srcIn),
                  //        child: Container(
                  //            width: 39,
                  //            height: 39,
                  //            decoration: BoxDecoration(
                  //              image: DecorationImage(
                  //                  image: (showImage), fit: BoxFit.fitWidth),
                  //              // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                  //            ))
                  //      ),
                ),
            ],
          ),
          SizedBox(
            height: screenHeight! * 0.01,
          ),
          // Text(
          //   title,
          //   textAlign: TextAlign.left,
          //   style: TextStyle(
          //       color: const Color.fromRGBO(69, 69, 69, 1),
          //       decoration: TextDecoration.none,
          //       fontFamily: 'Inter',
          //       fontSize: fontSize,
          //       fontWeight: FontWeight.normal,
          //       height: 1),
          // )
        ],
      ),
    );
  }

  void showDialogCustomMarkers() {
    double? outerCircleCorner = 35;
    //double? outerCircleSize = screenHeight! * 0.09;
    // double? innerCircleSize = outerCircleSize * 0.34;
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          height: MediaQuery.of(context).size.height * 0.50,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color.fromARGB(225, 53, 54, 54),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(outerCircleCorner),
                              topRight: Radius.circular(outerCircleCorner),
                              bottomLeft: Radius.circular(outerCircleCorner),
                              bottomRight: Radius.circular(outerCircleCorner),
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.80,
                              height: MediaQuery.of(context).size.height * 0.50,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(outerCircleCorner),
                              topRight: Radius.circular(outerCircleCorner),
                              bottomLeft: Radius.circular(outerCircleCorner),
                              bottomRight: Radius.circular(outerCircleCorner),
                            ),
                            // color: Color.fromARGB(225, 53, 54, 54),
                            color: Colors.transparent,
                          ),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          padding: const EdgeInsets.all(10),
                          //margin: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight! * 0.02,),
                              Text(
                                selectTitle,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: AppConstants.txtColor1,
                                    fontFamily: 'Inter',
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                    height: 1),
                              ),
                              SizedBox(height: screenHeight! * 0.02,),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(height: screenHeight! * 0.015,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          customMarkersPaletteBox(AppConstants.markerCircle, "Circle,"),
                                          customMarkersPaletteBox(AppConstants.markerPlus, "PLus"),
                                          customMarkersPaletteBox(AppConstants.markerHexagon, "Hexagon"),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight! * 0.03,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          customMarkersPaletteBox(AppConstants.markerHollowCircle, "Circle"),
                                          customMarkersPaletteBox(AppConstants.markerHollowSquare, "Square"),
                                          customMarkersPaletteBox(AppConstants.markerMoon, "Moon"),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight! * 0.03,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          customMarkersPaletteBox(AppConstants.markerSquare, "Square"),
                                          customMarkersPaletteBox(AppConstants.markerStar, "Star"),
                                          customMarkersPaletteBox(AppConstants.markerTriangle, "Triangle"),
                                        ],
                                      ),
                                      // SizedBox(height: screenHeight! * 0.03,),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //   mainAxisSize: MainAxisSize.max,
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     customMarkersPaletteBox(AppConstants.plusImg, "Plus"),
                                      //   ],
                                      // ),
                                      SizedBox(height: screenHeight! * 0.03,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget customMarkersDialog() {
    return Container();
  }

  Widget layoutPaletteBox(AssetImage showImage, String title) {
    double? outerCircleCorner = 15;
    double? outerCircleSize = screenHeight! * 0.09;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (title == "Standard") {
          selectedLayout = 2;
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
                  color: AppConstants.altColor,
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
                ' ',
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

  void pickMarkerFromDevice() {
    _getFromGallery();
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // 5. Get the path to the apps directory so we can save the file to it.
      final pathGot = await getApplicationDocumentsDirectory();
      debugPrint(pathGot.path);
      // get the image's directory
      //final fileName = p.basename(pickedFile.path);
      //final extension = p.extension(pickedFile.path);
      const fileNameToSave = (AppConstants.customImageName);
      // copy the image's whole directory to a new <File>
      final File localImage =
          await imageFile.copy('${pathGot.path}/$fileNameToSave');
      debugPrint(localImage.path);
      setState(() {
        pickedImage = imageFile;
      });
    }
  }
}
