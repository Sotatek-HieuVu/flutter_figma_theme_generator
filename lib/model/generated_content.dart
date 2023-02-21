import 'package:json_annotation/json_annotation.dart';

part 'generated_content.g.dart';

@JsonSerializable()
class GeneratedContent {
  final Map<String, String> files;
  final List<String> warnings;
  final String? themeInstanceName;

  GeneratedContent(this.files, this.warnings, [this.themeInstanceName]);
  factory GeneratedContent.fromJson(Map<String, dynamic> json) =>
      _$GeneratedContentFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedContentToJson(this);
}
