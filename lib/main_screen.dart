import 'dart:async';
import 'dart:ffi';

import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

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

  double FPS = 30;

  late Timer timer;
  bool stopRecordingBool = false;

  String selectTitle = "Select Color";
  double progressSize = 0.25;
  String progressInt = "1";
  bool showBack = false;

  double _currentSliderValue = 10;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    listenAllSensors();
    print(Duration.microsecondsPerSecond ~/FPS);
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
          stopRecordingBool = false;
          startRecording();
          print("On Double Tap");
        },
        onLongPress: () {
          stopRecordingBool = true;
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
                          //print(value);
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
                          //print(value);
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

  startRecording() {
    timer = Timer.periodic(Duration(microseconds: Duration.microsecondsPerSecond ~/FPS), (timer) {
        if (stopRecordingBool) {
        stopRecording();
      }
      if(!stopRecordingBool) {
        int timeStamp = DateTime.now().microsecondsSinceEpoch;
        print("$timeStamp : $_accelerometerValues");

        // Only When Changed Values
        /*if(old_accelerometerValues != _accelerometerValues.toString()){
          List<String> accelerometerValue = [timeStamp.toString(),_accelerometerValues.toString()];
          _accelerometerValues_List.add(accelerometerValue);
        }
        old_accelerometerValues = _accelerometerValues.toString();*/

        //All the Data
        List<String> accelerometerValue = [timeStamp.toString(),_accelerometerValues.toString()];
        _accelerometerValues_List.add(accelerometerValue);

        List<String> gyroscopeValue = [timeStamp.toString(),_gyroscopeValues.toString()];
        _gyroscopeValues_List.add(gyroscopeValue);
      }
    });
  }

  stopRecording(){
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
                  header.add('AccelerometerValues');
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

  void listenAllSensors(){
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

  void TestCsv(){
    List<String> header = [];
    header.add('No.');
    header.add('User Name');
    header.add('Mobile');
    header.add('ID Number');
    List<List<String>> listOfLists = []; //Outter List which contains the data List
    List<String> data1 = ['1','Bilal Saeed','1374934','912839812']; //Inner list which contains Data i.e Row
    List<String> data2 = ['2','Ahmar','21341234','192834821']; //Inner list which contains Data i.e Row
    listOfLists.add(data1);
    listOfLists.add(data2);
    exportCSV.myCSV(header, listOfLists);
  }

  void TestCsv_new(){
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
