// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs


import 'package:chroma_plus_flutter/Sample/ColorPicker.dart';
import 'package:chroma_plus_flutter/customise_layout.dart';
import 'package:chroma_plus_flutter/main_screen.dart';
import 'package:chroma_plus_flutter/select_color.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import 'CustomError.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      builder: (BuildContext context, Widget? widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomError(errorDetails: errorDetails);
        };
        return widget!;
      },

      debugShowCheckedModeBanner: false,
      title: 'Chroma+',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SelectColor(),
      routes: <String, WidgetBuilder>{
        '/selectColor': (BuildContext context) => SelectColor(),
        '/mainScreen': (BuildContext context) => const MainScreen(),
        '/customiseLayout': (BuildContext context) => const CustomiseLayout(),
        '/colorPicker': (BuildContext context) => ColorPicker(200),
      },
    );
  }
}