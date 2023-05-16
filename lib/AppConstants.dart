
import 'package:flutter/cupertino.dart';

class AppConstants{

  static const int holdTime = 2000;

  static const Color bgColor = Color.fromRGBO(32, 35, 32, 1);
  static const Color altColor = Color.fromRGBO(111, 111, 111, 1);
  static const Color txtColor1 = Color.fromRGBO(111, 111, 111, 1);
  static const Color greenColor = Color.fromRGBO(11, 182, 8, 1);
  static const Color greenAltColor = Color.fromRGBO(134, 255, 91, 1);
  static const Color blueColor = Color.fromRGBO(11, 8, 182, 1);
  static const Color blackColor = Color.fromRGBO(0, 0, 0, 1);
  static const Color redColor = Color.fromRGBO(252, 3, 3, 1);

  static const Color buttonGreyColor = Color.fromARGB(65, 0, 0, 0);
  static const Color buttonTxtColor = Color.fromRGBO(69, 69, 69, 1);

  static const Color whiteTxtColor = Color.fromARGB(200, 255, 255, 255);

  static const Color sliderActiveColor = Color.fromARGB(255, 210, 210, 210);
  static const Color sliderInActiveColor = Color.fromARGB(255, 210, 210, 210);

  static const Color containerGreyColor = Color.fromARGB(65, 0, 0, 0);

  static const AssetImage plusImg = AssetImage('assets/images/plusImg.png');
  static const AssetImage triangleImg = AssetImage('assets/images/triangleImg.png');
  static const AssetImage sfCircleImg = AssetImage('assets/images/sfMarker.png');

  static const AssetImage addMarkerImg = AssetImage('assets/images/addMarker.png');
  static const AssetImage colorCircleImg = AssetImage('assets/images/colorCirlce.png');

  static const AssetImage customImg = AssetImage('assets/images/settings.png');
  static const AssetImage standardImg = AssetImage('assets/images/standardLayout.png');

  static const AssetImage backImg = AssetImage('assets/images/backButton.png');
  static const AssetImage forwardImg = AssetImage('assets/images/rightButton.png');

  static const String customImageName = "custom_img.png";

  // Main Scree Icons
  static const AssetImage startRecordImg = AssetImage('assets/images/startRecordImg.png');

  static const AssetImage stopRecordImg = AssetImage('assets/images/stopRecordImg.png');

  static const AssetImage folderImg = AssetImage('assets/images/foldersImg.png');

  static const AssetImage exportImg = AssetImage('assets/images/exportImg.png');

  static const AssetImage backImgWhite = AssetImage('assets/images/backButtonWhite.png');

  static var customShapes = [markerCircle,markerCross,markerHexagon,markerHollowCircle,markerHollowSquare
                            ,markerMoon, markerSquare, markerStar, markerTriangle];

  static const AssetImage markerCircle = AssetImage('assets/images/circle.png');
  static const AssetImage markerCross = AssetImage('assets/images/cross.png');
  static const AssetImage markerPlus = AssetImage('assets/images/plus.png');
  static const AssetImage markerHexagon = AssetImage('assets/images/hexagon.png');
  static const AssetImage markerHollowCircle = AssetImage('assets/images/hollow_circle.png');
  static const AssetImage markerHollowSquare = AssetImage('assets/images/hollow_square.png');
  static const AssetImage markerMoon = AssetImage('assets/images/moon.png');
  static const AssetImage markerSquare = AssetImage('assets/images/square.png');
  static const AssetImage markerStar = AssetImage('assets/images/star.png');
  static const AssetImage markerTriangle = AssetImage('assets/images/triangle.png');

}