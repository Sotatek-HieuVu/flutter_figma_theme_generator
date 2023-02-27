extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
String removeSpecial(String value) {
  var value0 = value;
  if (!RegExp(r"^[a-zA-Z][\w]*$").hasMatch(value)) {
    value0 = value.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  }
  return value0;
}
bool _isColorConfig(dynamic data) =>
    data is Map<String, dynamic> && data['type'] == 'Color-config';

bool _isColor(dynamic data) =>
    data is Map<String, dynamic> && data['type'] == 'color';