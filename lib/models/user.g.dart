// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..textbookId = json['textbookId'] as num
    ..studentCode = json['studentCode'] as String
    ..mobile = json['mobile'] as String
    ..tRealName = json['tRealName'] as String
    ..className = json['className'] as String
    ..userName = json['userName'] as String
    ..userId = json['userId'] as num
    ..starTotal = json['starTotal'] as num
    ..volume = json['volume'] as num
    ..wkcyTime = json['wkcyTime'] as num
    ..realName = json['realName'] as String
    ..classId = json['classId'] as num
    ..stuIdentityState = json['stuIdentityState'] as num
    ..grade = json['grade'] as num
    ..schoolId = json['schoolId'] as num
    ..schoolName = json['schoolName'] as String
    ..vip = json['vip'] as String
    ..tUserName = json['tUserName'] as String
    ..key = json['key'] as String
    ..headUrl = json['headUrl'] as String
    ..parentUsername = json['parentUsername'] as String
    ..parentId = json['parentId'] as num;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'textbookId': instance.textbookId,
      'studentCode': instance.studentCode,
      'mobile': instance.mobile,
      'tRealName': instance.tRealName,
      'className': instance.className,
      'userName': instance.userName,
      'userId': instance.userId,
      'starTotal': instance.starTotal,
      'volume': instance.volume,
      'wkcyTime': instance.wkcyTime,
      'realName': instance.realName,
      'classId': instance.classId,
      'stuIdentityState': instance.stuIdentityState,
      'grade': instance.grade,
      'schoolId': instance.schoolId,
      'schoolName': instance.schoolName,
      'vip': instance.vip,
      'tUserName': instance.tUserName,
      'key': instance.key,
      'headUrl': instance.headUrl,
      'parentUsername': instance.parentUsername,
      'parentId': instance.parentId
    };
