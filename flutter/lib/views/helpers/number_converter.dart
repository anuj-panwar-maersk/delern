import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;

int convertColorValueToHex(int value) {
  final hexValue = '0x${value.toRadixString(16)}';
  return int.parse(hexValue, onError: (hexValue) {
    error_reporting.report(
        FormatException('Exception converting color value to hex: $hexValue'));
    return null;
  });
}
