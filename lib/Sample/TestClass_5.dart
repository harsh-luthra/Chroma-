import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_svg/svg.dart';

class TestClass_5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator Iphone13promax31Widget - FRAME
    return Container(
        width: 428,
        height: 926,
        decoration: BoxDecoration(
          color : Color.fromRGBO(70, 69, 69, 1),
        ),
        child: Stack(
            children: <Widget>[
              Positioned(
                  top: 0,
                  left: -14,
                  child: SvgPicture.asset(
                      'assets/images/rectangle2.svg',
                      semanticsLabel: 'rectangle2'
                  ),
              ),Positioned(
                  top: 662,
                  left: 188,
                  child: Text('4 of 4', textAlign: TextAlign.left, style: TextStyle(
                      color: Color.fromRGBO(105, 105, 105, 1),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1
                  ),)
              ),Positioned(
                  top: 639,
                  left: 127,
                  child: Container(
                      width: 184,
                      height: 9,

                      child: Stack(
                          children: <Widget>[
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                    width: 184,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      borderRadius : BorderRadius.only(
                                        topLeft: Radius.circular(38.84709167480469),
                                        topRight: Radius.circular(38.84709167480469),
                                        bottomLeft: Radius.circular(38.84709167480469),
                                        bottomRight: Radius.circular(38.84709167480469),
                                      ),
                                      color : Color.fromRGBO(111, 109, 109, 1),
                                    )
                                )
                            ),
                          ]
                      )
                  )
              ),Positioned(
                  top: 639,
                  left: 127,
                  child: Container(
                      width: 184,
                      height: 9,

                      child: Stack(
                          children: <Widget>[
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                    width: 184,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      borderRadius : BorderRadius.only(
                                        topLeft: Radius.circular(38.84709167480469),
                                        topRight: Radius.circular(38.84709167480469),
                                        bottomLeft: Radius.circular(38.84709167480469),
                                        bottomRight: Radius.circular(38.84709167480469),
                                      ),
                                      color : Color.fromRGBO(138, 255, 96, 1),
                                    )
                                )
                            ),
                          ]
                      )
                  )
              ),Positioned(
                  top: 420,
                  left: 122,
                  child: Container(
                      width: 184,
                      height: 85.27410888671875,

                      child: Stack(
                          children: <Widget>[
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                    width: 184,
                                    height: 85.27410888671875,
                                    decoration: BoxDecoration(
                                      borderRadius : BorderRadius.only(
                                        topLeft: Radius.circular(21.792272567749023),
                                        topRight: Radius.circular(21.792272567749023),
                                        bottomLeft: Radius.circular(21.792272567749023),
                                        bottomRight: Radius.circular(21.792272567749023),
                                      ),
                                      color : Color.fromRGBO(123, 123, 123, 1),
                                    )
                                )
                            ),
                          ]
                      )
                  )
              ),Positioned(
                  top: 454,
                  left: 180,
                  child: Text('Launch', textAlign: TextAlign.left, style: TextStyle(
                      color: Color.fromRGBO(32, 32, 32, 1),
                      fontFamily: 'Inter',
                      fontSize: 15,
                      letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1
                  ),)
              ),Positioned(
                  top: 659,
                  left: 136,
                  child: Container(
                      width: 40,
                      height: 25,

                      child: Stack(
                          children: <Widget>[
                            Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                    width: 40,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius : BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                      border : Border.all(
                                        color: Color.fromRGBO(44, 44, 44, 1),
                                        width: 1,
                                      ),
                                    )
                                )
                            ),Positioned(
                                top: 7,
                                left: 24,
                                child: Transform.rotate(
                                  angle: -180 * (math.pi / 180),
                                  child: SvgPicture.asset(
                                      'assets/images/rightarrow.svg',
                                      semanticsLabel: 'rightarrow2'
                                  ),
                                )
                            ),
                          ]
                      )
                  )
              ),Positioned(
                  top: 214,
                  left: 141,
                  child: Text('CHROMA+', textAlign: TextAlign.left, style: TextStyle(
                      color: Color.fromRGBO(111, 111, 111, 1),
                      fontFamily: 'Inter',
                      fontSize: 30,
                      letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1
                  ),)
              ),Positioned(
                  top: 250,
                  left: 170,
                  child: Text('by Scissor Films', textAlign: TextAlign.left, style: TextStyle(
                      color: Color.fromRGBO(111, 111, 111, 1),
                      fontFamily: 'Proxima Nova',
                      fontSize: 15,
                      letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1
                  ),)
              ),
            ]
        )
    );
  }
}
