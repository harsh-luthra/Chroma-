import 'package:chroma_plus_flutter/AppConstants.dart';
import 'package:flutter/material.dart';

class SelectColor extends StatelessWidget {
  double? screenWidth;
  double? screenHeight;

  SelectColor({super.key});

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
              const Text(
                'CHROMA+',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: AppConstants.txtColor1,
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
              const Text(
                'by Scissor Films',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: AppConstants.txtColor1,
                    fontFamily: 'Proxima Nova',
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    height: 1),
              ),
              SizedBox(height: screenHeight! * 0.13),
              const Text(
                'Select Color',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: AppConstants.txtColor1,
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  colorPalette(AppConstants.greenColor, "Green"),
                  const SizedBox(
                    width: 10,
                  ),
                  colorPalette(AppConstants.blueColor, "Blue"),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  colorPalette(AppConstants.blackColor, "Black"),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        print("Custom Tapped");
                      },
                      child: colorPalette(AppConstants.redColor, "Custom")),
                ],
              ),
              const SizedBox(height: 20),
              progressBarSized(0.3),
              const SizedBox(height: 15),
              const Text(
                '1 of 4',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(105, 105, 105, 1),
                    fontFamily: 'Inter',
                    fontSize: 14,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget colorPalette(Color color, String title) {
    double? outerCircleCorner = 18;
    double? outerCircleSize = screenHeight! * 0.09;
    double? innerCircleSize = outerCircleSize * 0.34;
    return Column(
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
            Container(
              width: innerCircleSize,
              height: innerCircleSize,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(38.84709167480469),
                  topRight: Radius.circular(38.84709167480469),
                  bottomLeft: Radius.circular(38.84709167480469),
                  bottomRight: Radius.circular(38.84709167480469),
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
              fontSize: 10,
              fontWeight: FontWeight.normal,
              height: 1),
        )
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
}
