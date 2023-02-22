import 'package:json_annotation/json_annotation.dart';

part 'generated_typography.g.dart';

@JsonSerializable()
class GeneratedTypography {
  final String? fontFamily;
  final String? fontSize;
  final String? fontWeight;
  final String? lineHeight;
  final String? letterSpacing;
  final String? textDecoration;
  final String? textCase;
  GeneratedTypography({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.letterSpacing,
    this.textDecoration,
    this.textCase,
  });
  factory GeneratedTypography.fromJson(Map<String, dynamic> json) =>
      _$GeneratedTypographyFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedTypographyToJson(this);
}
