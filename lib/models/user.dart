import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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
    factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);
    Map<String, dynamic> toJson() => _$UserToJson(this);
}
