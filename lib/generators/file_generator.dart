import 'dart:math';
import 'package:flutter_figma_theme_generator/config/pubspec_config.dart';
import 'package:flutter_figma_theme_generator/generators/theme_generator.dart';
import 'package:flutter_figma_theme_generator/model/generated_content.dart';
import 'package:flutter_figma_theme_generator/model/generated_value.dart';
import 'package:flutter_figma_theme_generator/utils/case_utils.dart';

class FileGenerator extends BaseGenerator {
  final _warnings = <String>[];

  @override
  bool matchesSchema(Map<String, dynamic> schema) => schema != null;

  @override
  GeneratedContent generate(
      Map<String, dynamic> schema, String path, PubspecConfig pubspecConfig) {
    _warnings.clear();

    final colorPalette = schema;
    final colors = <String, dynamic>{};
    final files = <String, String>{};
    for (final entry in colorPalette.entries) {
      final json = entry.value as Map<String, dynamic>;
      colors.addAll(_generateColors(entry.key, json, colorPalette));
    }
    var colorFile = '';
    // var fileName = path.snakeCase;
    var fileName = path;
    colorFile +=
        '''import 'package:${pubspecConfig.projectName}/styles/import.dart';\n\n''';
    colorFile += colors.entries.map((color) {
      var key = color.key;
      if (!RegExp(r"^[a-zA-Z][\w]*$").hasMatch(color.key)) {
        key = color.key.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      }
      if (color.value is String) {
        if (color.value.startsWith("FontWeight") ||
            color.value.startsWith("TextDecoration")) {
          return 'const $key = ${color.value};\n';
        }
        if (color.value.startsWith("#")) {
          // return 'Color $key = HexColor.fromHex("${color.value}");\n';
          return 'const $key = Color(0xff${color.value.toString().replaceFirst('#', '')});\n';
        }
        if (color.value.startsWith("rgba")) {
          List rgbaList =
              color.value.substring(5, color.value.length - 1).split(",");
          if (rgbaList.length == 2) {
            var color0 = '';
            if (rgbaList[0] is String &&
                rgbaList[0].toString().startsWith('{') &&
                rgbaList[0].toString().endsWith('}')) {
              color0 = rgbaList[0]
                  .toString()
                  .replaceFirst('{', '')
                  .replaceFirst('}', '')
                  .camelCase;
            }
            return 'Color $key = $color0.withOpacity(${(int.parse((rgbaList[1].replaceAll(RegExp('[^0-9]'), '')))) / 100});\n';
          }
          return 'const $key = Color.fromRGBO(${int.parse(rgbaList[0])}, ${int.parse(rgbaList[1])}, ${int.parse(rgbaList[2])}, ${double.parse(rgbaList[3])});\n';
        }
        if (color.value.startsWith("rgb")) {
          List rgbList = color.value
              .substring(4, color.value.length - 1)
              .split(",")
              .map((c) => int.parse(c))
              .toList();
          return 'const $key = Color.fromRGBO(${rgbList[0]}, ${rgbList[1]}, ${rgbList[1]}, 1.0);\n';
        }
        if (color.value.startsWith("linear-gradient")) {
          return 'const LinearGradient ${color.key} = ${linearGradientColor(color.value)};\n';
        }
        if (color.value.startsWith("{") && color.value.endsWith("}")) {
          var colorValue = (color.value
                  .replaceFirst('{', '')
                  .replaceFirst('}', '') as String)
              .camelCase;
          return 'const $key = $colorValue;\n';
        }
        if (color.value.startsWith("\$")) {
          var colorValue =
              (color.value.replaceFirst('\$', '') as String).camelCase;
          return 'const $key = $colorValue;\n';
        }
        if (isNumeric(color.value)) {
          return 'const $key = ${int.parse(color.value)};\n';
        }
      } else if (color.value is Map<String, dynamic>) {
        var valueFile = '';
        valueFile += '{\n';
        color.value.forEach((k, v) {
          valueFile += '  "$k": ';
          if (v is String && v.startsWith("{") && v.endsWith("}")) {
            var valueFile0 =
                v.replaceFirst('{', '').replaceFirst('}', '').camelCase;
            if (valueFile0.contains('%')) {
              valueFile0 = valueFile0.replaceFirst('%', '');
            }
            valueFile += valueFile0;
          } else if (v is String && v.startsWith('\$')) {
            var valueFile0 = v.replaceFirst('\$', '').camelCase;
            valueFile += valueFile0;
          } else {
            valueFile += '"$v"';
          }
          valueFile += ',\n';
        });
        valueFile += '}';
        return 'const $key = $valueFile;\n';
      } else if (color.value is List) {
        var valueFile = '';
        valueFile += '[\n';
        color.value.forEach((element) {
          if (element is Map) {
            valueFile += '  {\n';
            element.forEach((key, value) {
              valueFile += '    "$key": "$value",\n';
            });
            valueFile += '  },\n';
          }
        });
        valueFile += ']';
        return 'const $key = $valueFile;\n';
      }
      return 'const $key = "${color.value}";\n';
    }).join();
    files[fileName] = colorFile;
    return GeneratedContent(files, _warnings);
  }

  Map<String, dynamic> _generateColors(String key, Map<String, dynamic> data,
      Map<String, dynamic> colorPalette) {
    final colors = <String, dynamic>{};
    try {
      var jsonData = GeneratedValue.fromJson(data);
      switch (jsonData.type) {
        case "fontWeights":
          switch (jsonData.value) {
            case "Bold":
              colors[key.camelCase] = 'FontWeight.bold';
              break;
            case "Regular":
              colors[key.camelCase] = 'FontWeight.w400';
              break;
            case "SemiBold":
              colors[key.camelCase] = 'FontWeight.w600';
              break;
          }
          break;
        case "textDecoration":
          if (jsonData.value == "Underline") {
            colors[key.camelCase] = 'TextDecoration.underline';
          } else if (jsonData.value == "none") {
            colors[key.camelCase] = 'TextDecoration.none';
          }
          break;
        default:
          if (jsonData.value is String) {
            colors[key.camelCase] = '${jsonData.value}'.replaceAll('%', '');
          } else if (jsonData.value is Map<String, dynamic>) {
            colors[key.camelCase] = jsonData.value;
          } else if (jsonData.value is List) {
            colors[key.camelCase] = jsonData.value;
          }
      }
    } catch (e) {
      for (final entry in data.entries) {
        if (entry.value is Map<String, dynamic>) {
          colors.addAll(_generateColors('${key}_${entry.key}'.camelCase,
              entry.value as Map<String, dynamic>, colorPalette));
        }
      }
    }
    return colors;
  }

  String hslToHex(double hue, double saturation, double light, double opacity) {
    light /= 100;
    final a = saturation * min(light, 1 - light) / 100;
    final red = calucalateHex(0, hue, saturation, light, a);
    final green = calucalateHex(8, hue, saturation, light, a);
    final blue = calucalateHex(4, hue, saturation, light, a);
    final alpha = (255 * opacity).round().toRadixString(16).padLeft(2, '0');
    return '0x${'$alpha$red$green$blue'.toUpperCase()}';
  }

  String calucalateHex(
      int n, double hue, double saturation, double light, double a) {
    final k = (n + hue / 30) % 12;
    final color = light - a * max(min(k - 3, min(9 - k, 1)), -1);
    return (255 * color)
        .round()
        .toRadixString(16)
        .padLeft(2, '0'); // convert to Hex and prefix "0" if needed
  }

  bool _isColorConfig(dynamic data) =>
      data is Map<String, dynamic> && data['type'] == 'Color-config';

  bool _isColor(dynamic data) =>
      data is Map<String, dynamic> && data['type'] == 'color';
  bool isNumeric(String str) {
    try {
      var value = int.parse(str);
      return true;
    } on FormatException {
      return false;
    }
  }

  String removeSpecial(String value) {
    var value0 = value;
    if (!RegExp(r"^[a-zA-Z][\w]*$").hasMatch(value)) {
      value0 = value.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    }
    return value0;
  }

  String linearGradientColor(String colorStr) {
    //linear-gradient(45deg, #6562E7 0%, #B49AE5 50%, #73DFD7 100%)
    var colorStr0 = colorStr
        .replaceFirst('linear-gradient', '')
        .replaceFirst('(', '')
        .replaceFirst(')', '');
    var arrColor = colorStr0.split(',');
    var linearGradient = '';
    var begin = '';
    var end = '';
    for (var element in arrColor) {
      if (element == '45deg') {
        begin = 'Alignment.bottomLeft';
        end = 'Alignment.topRight';
      } else if (element == '90deg') {
        begin = 'Alignment.centerLeft';
        end = 'Alignment.centerRight';
      }
      if (element.trim().startsWith('#')) {
        var arr = element.trim().split(' ');
        linearGradient +=
            '      Color(0x${prefixColor(arr[1])}${arr[0].replaceFirst('#', '')}),\n';
      }
    }
    return 'LinearGradient(\n    begin: $begin,\n    end: $end, \n    colors: [\n$linearGradient    ])';
  }

  String hexOrRGBToColor(String colorStr) {
    RegExp hexColorRegex =
        RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    if (colorStr.startsWith("rgba")) {
      List rgbaList = colorStr.substring(5, colorStr.length - 1).split(",");
      return 'Color.fromRGBO(${int.parse(rgbaList[0])}, ${int.parse(rgbaList[1])}, ${int.parse(rgbaList[2])}, ${double.parse(rgbaList[3])})';
    } else if (colorStr.startsWith("rgb")) {
      List rgbList = colorStr
          .substring(4, colorStr.length - 1)
          .split(",")
          .map((c) => int.parse(c))
          .toList();
      return 'Color.fromRGBO(${rgbList[0]}, ${rgbList[1]}, ${rgbList[1]}, 1.0)';
    } else if (hexColorRegex.hasMatch(colorStr)) {
      if (colorStr.length == 4) {
        colorStr = colorStr + colorStr.substring(1, 4);
      }
      if (colorStr.length == 7) {
        int colorValue = int.parse(colorStr.substring(1), radix: 16);
        return 'Color($colorValue)';
      } else {
        int colorValue = int.parse(colorStr.substring(1, 7), radix: 16);
        double opacityValue =
            int.parse(colorStr.substring(7), radix: 16).toDouble() / 255;
        return 'Color($colorValue).withOpacity($opacityValue)';
      }
    } else if (colorStr.isEmpty) {
      throw UnsupportedError("Empty color field found.");
    } else if (colorStr == 'none') {
      return 'Colors.transparent';
    } else {
      return 'Colors.transparent';
      // throw UnsupportedError(
      //     "Only hex, rgb, or rgba color format currently supported. String:  $colorStr");
    }
  }

  prefixColor(String percent) {
    if (!percent.endsWith('%')) {
      percent = '$percent%';
    }
    switch (percent) {
      case '95%':
        return 'F2';
      case '90%':
        return 'E6';
      case '85%':
        return 'D9';
      case '80%':
        return 'CC';
      case '75%':
        return 'BF';
      case '70%':
        return 'B3';
      case '65%':
        return 'A6';
      case '60%':
        return '99';
      case '55%':
        return '8C';
      case '50%':
        return '80';
      case '45%':
        return '73';
      case '40%':
        return '66';
      case '35%':
        return '59';
      case '30%':
        return '4D';
      case '25%':
        return '40';
      case '20%':
        return '33';
      case '15%':
        return '26';
      case '10%':
        return '1A';
      case '5%':
        return '0D';
      case '0%':
        return '00';
      case '100%':
      default:
        return 'FF';
    }
  }
}
