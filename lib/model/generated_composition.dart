import 'package:json_annotation/json_annotation.dart';

part 'generated_composition.g.dart';

@JsonSerializable()
class GeneratedComposition {
  final String fill,
      paddingTop,
      paddingRight,
      paddingBottom,
      paddingLeft,
      borderRadius,
      itemSpacing,
      width,
      height,
      verticalPadding,
      horizontalPadding;
  GeneratedComposition({
    this.fill = '',
    this.paddingTop = '',
    this.paddingRight = '',
    this.paddingBottom = '',
    this.paddingLeft = '',
    this.borderRadius = '',
    this.itemSpacing = '',
    this.width = '',
    this.height = '',
    this.verticalPadding = '',
    this.horizontalPadding = '',
  });
  factory GeneratedComposition.fromJson(Map<String, dynamic> json) =>
      _$GeneratedCompositionFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedCompositionToJson(this);
}
