import 'package:json_annotation/json_annotation.dart';

part 'generated_boxShadow.g.dart';

@JsonSerializable()
class GeneratedBoxShadow {
  final String x,
      y,
      blur,
      spread,
      color,
      type;
  GeneratedBoxShadow({
    this.x = '',
    this.y = '',
    this.blur = '',
    this.spread = '',
    this.color = '',
    this.type = '',
  });
  factory GeneratedBoxShadow.fromJson(Map<String, dynamic> json) =>
      _$GeneratedBoxShadowFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedBoxShadowToJson(this);
}
