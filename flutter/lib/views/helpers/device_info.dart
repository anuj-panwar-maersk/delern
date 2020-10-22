import 'dart:async';
import 'dart:io';

import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class DeviceInfo {
  final String userFriendlyName;
  final Map<String, dynamic> info;

  static DeviceInfo _instance;

  DeviceInfo._({
    @required this.userFriendlyName,
    @required Map<String, dynamic> info,
  })  : assert(userFriendlyName != null),
        assert(info != null),
        info = Map<String, dynamic>.unmodifiable(info);

  static Future<DeviceInfo> getDeviceInfo() async {
    if (_instance == null) {
      // Set default instance with basic info if everything else fails.
      _instance = DeviceInfo._(
        userFriendlyName: Platform.operatingSystem,
        info: <String, String>{
          // Ex.: android Linux 3.2.1 SMP etc.
          'OS':
              '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          // Ex.: 2.1.0-dev-flutter etc.
          'Dart': Platform.version,
        },
      );

      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          final userFriendlyName =
              '${androidInfo.manufacturer} ${androidInfo.model}';
          // https://developer.android.com/reference/android/os/Build.VERSION
          _instance = DeviceInfo._(
            userFriendlyName: userFriendlyName,
            info: <String, dynamic>{
              'Device': userFriendlyName,
              'Android version': androidInfo.version.release,
              'Android Security Patch level': androidInfo.version.securityPatch,
              'SDK': androidInfo.version.sdkInt,
            },
          );
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          // http://pubs.opengroup.org/onlinepubs/7908799/xsh/sysutsname.h.html
          _instance = DeviceInfo._(
            userFriendlyName: iosInfo.utsname.machine,
            info: <String, dynamic>{
              'Device': iosInfo.model,
              'iOS version': '${iosInfo.systemName} ${iosInfo.systemVersion}',
              'Version level of the release': iosInfo.utsname.version,
              'Hardware Type': iosInfo.utsname.machine,
            },
          );
        }
      } catch (e, stackTrace) {
        // Can't report directly because ErrorReporting uses this method.
        scheduleMicrotask(() {
          error_reporting.report(e, stackTrace: stackTrace);
        });
      }
    }
    return _instance;
  }

  /// Method check whether device is small. Found by trial and error
  static bool isDeviceSmall(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    if (mediaData.orientation == Orientation.portrait) {
      return mediaData.size.height < 620;
    }
    // In landscape device is small to prevent overlapping
    return true;
  }
}

/// If devices is phone, do not allow landscape orientation
void setDeviceOrientation() {
  WidgetsFlutterBinding.ensureInitialized();

  if (isPhone()) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}

bool isPhone() =>
    MediaQueryData.fromWindow(WidgetsBinding.instance.window)
        .size
        .shortestSide <
    600;
