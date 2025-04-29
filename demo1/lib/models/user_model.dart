import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.points,
  });

  // 从JSON映射到对象
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // 从对象映射到JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
