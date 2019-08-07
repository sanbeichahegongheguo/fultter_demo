part 'user.g.dart';

class User {
  User();
  num textbookId;
  String studentCode;
  String mobile;
  String tRealName;
  String className;
  String userName;
  num userId;
  num starTotal;
  num volume;
  num wkcyTime;
  String realName;
  num classId;
  num stuIdentityState;
  num grade;
  num schoolId;
  String schoolName;
  String vip;
  String tUserName;
  String key;
  String headUrl;
  String parentUsername;
  num parentId;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
