import 'dart:math';
import 'package:flutter_figma_theme_generator/config/pubspec_config.dart';
import 'package:flutter_figma_theme_generator/generators/theme_generator.dart';
import 'package:flutter_figma_theme_generator/model/generated_content.dart';
import 'package:flutter_figma_theme_generator/utils/case_utils.dart';

class ColorGenerator extends BaseGenerator {
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
    var fileName = path.snakeCase;
    // if(!File('lib/styles/$fileName').existsSync()){
    //   // colorFile += '''import 'package:flutter/material.dart';\n\n''';
    //   // colorFile += 'class ${fileName.upperCamelCase} {\n';
    // }
    colorFile +=
        '''import 'package:${pubspecConfig.projectName}/styles/import.dart';\n\n''';
    // colorFile +=
    //     '''import 'package:flutter/material.dart';\n\n''';
    colorFile += colors.entries.map((color) {
      // if (color.value.startsWith("linear-gradient")) {
      //   return '  static LinearGradient ${color.key} = ${linearGradientColor(color.value)};\n';
      // } else if (color.value.startsWith("{") && color.value.endsWith("}")) {
      //   var colorValue =
      //       color.value.replaceFirst('{', '').replaceFirst('}', '').camelCase;
      //   return '  static const ${color.key} = $colorValue;\n';
      // }
      // return '  static const ${color.key} = ${hexOrRGBToColor(color.value)};\n';
      var key = color.key;
      if (!RegExp(r"^[a-zA-Z][\w]*$").hasMatch(color.key)) {
        key = color.key.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      }
      if (color.value is String && color.value.startsWith("{") && color.value.endsWith("}")) {
        var colorValue =(color.value.replaceFirst('{', '').replaceFirst('}', '') as String).camelCase;
        return 'const $key = $colorValue;\n';
      }
      if (color.value is String && color.value.startsWith("\$")) {
        var colorValue =(color.value.replaceFirst('\$', '') as String).camelCase;
        return 'const $key = $colorValue;\n';
      }
      if (color.value is Map<String, dynamic>) {
        var colorValue = '';
        colorValue += '{';
        color.value.forEach((k,v){
          colorValue += '"$k"';
          colorValue += ' :';
          if(v is String && v.startsWith("{") && v.endsWith("}")){
            var colorValue0 = v.replaceFirst('{', '').replaceFirst('}', '').camelCase;
            if(colorValue0.contains('%')){
              colorValue0 = colorValue0.replaceFirst('%', '');
            }
            colorValue += colorValue0;
          }
          else if(v is String && v.startsWith('\$')){
            var colorValue0 = v.replaceFirst('\$', '').camelCase;
            colorValue += colorValue0;
          }
          else{
            colorValue += '"$v"';
          }
          colorValue += ', ';
        });
        colorValue += '}';
        return 'const $key = $colorValue;\n';
      }
      if (color.value is List) {
        // print('shadow100shadow100shadow100 ${color.value}');
        // var colorValue = '';
        // var value = '';
        // value += '[';
        // color.value.foEach((e){
        //   value += '{';
        //   value += '""';
        //   value += '},';
        // });
        // value += ']';
        // color.value.forEach((v){
        // });
        return 'const $key = "${color.value}";\n';
      }
      return 'const $key = "${color.value}";\n';
    }).join();
    // if(!File('lib/styles/$fileName').existsSync()){
    //   colorFile += '}\n';
    // }
    files[fileName] = colorFile;
    return GeneratedContent(files, _warnings);
  }

  Map<String, dynamic> _generateColors(String key, Map<String, dynamic> data,
      Map<String, dynamic> colorPalette) {
    final colors = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.key == 'value' && entry.value is String) {
        //&& _isColor(data)
        colors[key.camelCase] = '${entry.value}'.replaceAll('%', '');
      }
      else if (entry.key == 'value' && entry.value is Map<String, dynamic>){
        colors[key.camelCase] = entry.value;
      }
      if (entry.key == 'value' && entry.value is List){
        colors[key.camelCase] = entry.value;
      }
      else if (entry.value is Map<String, dynamic>) { //!_isColorConfig(entry.key) &&
        colors.addAll(_generateColors('${key}_${entry.key}'.camelCase,
            entry.value as Map<String, dynamic>, colorPalette));
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
  String removeSpecial(String value){
    var value0 = value ;
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
      if (element.trim().startsWith('#') && element.trim().endsWith('%')) {
        var arr = element.trim().split(' ');
        linearGradient +=
            '       const Color(0xff${arr[0].replaceFirst('#', '')}).withOpacity(${int.parse(arr[1].replaceFirst('%', '')) / 100}),\n';
      }
    }
    return 'LinearGradient(\n      begin: $begin,\n      end: $end, \n      colors: [\n$linearGradient      ])';
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
    } else if (colorStr.startsWith("#")) {
      return 'Color(0xff${colorStr.replaceFirst('#', '')})';
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
}
