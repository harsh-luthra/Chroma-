import 'dart:async';
import 'dart:io';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:chroma_plus_flutter/customise_layout.dart';
import 'package:chroma_plus_flutter/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SliderIndicatorPainter extends CustomPainter {
  final double position;

  _SliderIndicatorPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2), 12, Paint()..color = Colors.grey);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }

}

class SelectColor extends StatefulWidget {
  late double width = 200;

  // SelectColor(this.width);
  @override
  State<SelectColor> createState() => SelectColorState();
}

class SelectColorState extends State<SelectColor> {
  File? PickedImage;

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
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 255, 128),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 128, 128, 128),
  ];
  double _colorSliderPosition = 100;
  late double _shadeSliderPosition;
  late Color _currentColor;
  late Color _shadedColor;

  @override
  void initState() {
    super.initState();
    exitFullScreen();
    loadData();
    getCustomImage();
    setState(() {
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadeSliderPosition = widget.width / 2; //center the shader selector
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
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

  void SetColorSelectorData() {
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
    print("New pos: $position");
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
      print(
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
    double positionInColorArray =
        (position / widget.width * (_colors.length - 1));
    print(positionInColorArray);
    int index = positionInColorArray.truncate();
    print(index);
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
      print(msg);
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
              markerPaletteBox(AppConstants.addMarkerImg, "Custom"),
            ],
          ),
          // SizedBox(height: (screenHeight! * 0.09) + 10 + 10)
          SizedBox(height: screenHeight! * 0.01),
          colorSelectorSlider(),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: screenHeight! * 0.07,
                height: screenHeight! * 0.07,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  //color: AppConstants.altColor,
                  color: selectedColor,
                ),
              ),
               Container(
                width: (screenHeight! * 0.07) * 0.5,
                height: (screenHeight! * 0.07) * 0.5,
                 child: ColorFiltered(
                   colorFilter:
                   ColorFilter.mode(_shadedColor.withOpacity(1.0), BlendMode.srcIn),
                   child: Container(
                       width: 39,
                       height: 39,
                       decoration: BoxDecoration(
                         image: DecorationImage(
                             image: (AppConstants.plusImg), fit: BoxFit.fitWidth),
                         // DecorationImage(image: PickedImage == null ? showImage : Image.file(PickedImage), fit: BoxFit.fitWidth),
                       ))
                 ),
               ),
            ],
          ),
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
          print("_-------------------------STARTED DRAG");
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
          padding: EdgeInsets.all(15),
          child: Container(
            width: widget.width,
            height: 15,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(colors: _colors),
            ),
            child: CustomPaint(
              painter: _SliderIndicatorPainter(_colorSliderPosition),
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
          print("_-------------------------STARTED DRAG");
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
          padding: EdgeInsets.all(15),
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
              painter: _SliderIndicatorPainter(_shadeSliderPosition),
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
    printConsole("Saved Color $selectedColor");
    await prefrences.setString('selectedColor', selectedColor.toString());
    setState(() {
      //_shadedColor = selectedColor;
    });
  }

  void selectLayout() async {
    selectTitle = "Select Layout";
    progressInt = "3";
    progressSize = 0.75;
    showBack = true;
    printConsole("Saved Marker $selectedMarker");
    await prefrences.setString('selectedMarker', selectedMarker.toString());
    await prefrences.setString('selectedColor', selectedColor.toString());
    setState(() {
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (selectedLayout == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return MainScreen();
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
    double? markerSize = title == "Cross" ? screenHeight! * 0.045 : screenHeight! * 0.045;
    markerSize = title == "Circle" ? screenHeight! * 0.0625 : screenHeight! * 0.045;
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
            if(PickedImage == null){
              pickMarkerFromDevice();
            }else{
              selectedMarker = 3; // Need to Change to 3
              selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
              //pickMarkerFromDevice();
            }
          });
        }
      },
      onLongPress: (){
        if (title == "Custom") {
          setState(() {
          selectedMarker = 2; // Need to Change to 3
          // selectLayout(); // Need to Add Pick Image from Phone for Custom Marker
          pickMarkerFromDevice();
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
              (PickedImage == null || title != "Custom")
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
                  PickedImage!,
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
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // 5. Get the path to the apps directory so we can save the file to it.
      final pathGot = await getApplicationDocumentsDirectory();
      print(pathGot.path);
      // get the image's directory
      //final fileName = p.basename(pickedFile.path);
      //final extension = p.extension(pickedFile.path);
      const fileNameToSave = (AppConstants.customImageName);
      // copy the image's whole directory to a new <File>
      final File localImage = await imageFile.copy('${pathGot.path}/$fileNameToSave');
      print(localImage.path);
      setState(() {
        PickedImage = imageFile;
      });
    }
  }
}
