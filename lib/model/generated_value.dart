import 'package:json_annotation/json_annotation.dart';

part 'generated_value.g.dart';

@JsonSerializable()
class GeneratedValue {
  final dynamic value;
  final String type;
  GeneratedValue({required this.value, required this.type});
  factory GeneratedValue.fromJson(Map<String, dynamic> json) =>
      _$GeneratedValueFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedValueToJson(this);
}
