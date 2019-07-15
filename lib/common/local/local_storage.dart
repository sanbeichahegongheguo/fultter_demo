import 'package:flustars/flustars.dart';

///SharedPreferences 本地存储
class LocalStorage {
  static const String ACCOUNT_NUMBER = "account_number";
  static const String USERNAME = "username";
  static const String PASSWORD = "password";

  ///删掉单个账号
  static void delUser(LoginUser user) async {
    List<LoginUser> list = await getUsers();
    list.removeWhere((item) => item.username == user.username);
    saveUsers(list);
  }

  ///保存账号，如果重复，就将最近登录账号放在第一个
  static void saveUser(LoginUser user) async {
    List<LoginUser> list = await getUsers();
    addNoRepeat(list, user);
    saveUsers(list);
  }

  ///去重并维持次序
  static void addNoRepeat(List<LoginUser> users, LoginUser user) {
    users.removeWhere((item) => item.username == user.username);
    users.insert(0, user);
    if (users.length > 5) {
      users.removeLast();
    }
  }

  ///获取已经登录的账号列表
  static Future<List<LoginUser>> getUsers() async {
    List<LoginUser> list = new List();
    int num = SpUtil.getInt(ACCOUNT_NUMBER) ?? 0;
    for (int i = 0; i < num; i++) {
      String username = SpUtil.getString("$USERNAME$i");
      String password = SpUtil.getString("$PASSWORD$i");
      list.add(LoginUser(username, password));
    }
    return list;
  }

  ///保存账号列表
  static saveUsers(List<LoginUser> users) {
    int size = users.length;
    for (int i = 0; i < size; i++) {
      SpUtil.putString("$USERNAME$i", users[i].username);
      SpUtil.putString("$PASSWORD$i", users[i].password);
    }
    SpUtil.putInt(ACCOUNT_NUMBER, size);
  }
}

class LoginUser {
  String username;
  String password;
  LoginUser(this.username, this.password);
}
