import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:flutter/material.dart';

class GestureTest extends StatefulWidget {
  const GestureTest({Key? key}) : super(key: key);
  @override
  State<GestureTest> createState() => _GestureTestState();
}

class _GestureTestState extends State<GestureTest> {

  int fingers  = 0;


  @override
  Widget build(BuildContext context) {
    double? screenWidth = MediaQuery.of(context).size.width;
    double? screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: AppConstants.greenColor,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.center,
                  color: AppConstants.redColor,
                  width: screenWidth*0.8,
                  height: screenHeight*0.8,
                  child: GestureDetector(
                    onScaleStart: (de){
                      onThreeHold(de.pointerCount);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }

  void onThreeHold(int fingers_Count){
    if(fingers_Count == 3){
      print("3 FINGERS DETECTED");
    }
  }

}
