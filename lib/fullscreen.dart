import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FullScreen {
  // meothod channel instal
  static const MethodChannel _channel = MethodChannel('fullscreen');

  /// To enable fullscreen mode, pass the fullscreen mode as an argument the the enterFullScreen method of the FullScreen class.
  static Future<void> enterFullScreen(FullScreenMode fullScreenMode) async {
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode (SystemUiMode.immersiveSticky);
    } else if (Platform.isAndroid) {
      try {
        if (fullScreenMode == FullScreenMode.EMERSIVE) {
          // await _channel.invokeMethod('emersive');
        } else if (fullScreenMode == FullScreenMode.EMERSIVE_STICKY) {
          SystemChrome.setEnabledSystemUIMode (SystemUiMode.immersiveSticky);
          // await _channel.invokeMethod('emersiveSticky');
        } else if (fullScreenMode == FullScreenMode.LEANBACK) {
          // await _channel.invokeMethod('leanBack');
        }
      } catch (e) {
        debugPrint(e);
      }
    }
  }

  /// to get the current status of the SystemUI
  static Future<bool?> get isFullScreen async {
    bool? status;
    try {
      // status = await _channel.invokeMethod("status");
    } catch (e) {
      debugPrint(e);
    }
    return status;
  }

  /// Exit full screen
  static Future<void> exitFullScreen() async {
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (Platform.isAndroid) {
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        // await _channel.invokeMethod('exitFullScreen');
      } catch (e) {
        debugPrint(e);
      }
    }
  }
}

void debugPrint(msg){
  if (kDebugMode) {
    print(msg);
  }
}

enum FullScreenMode { EMERSIVE, EMERSIVE_STICKY, LEANBACK }
