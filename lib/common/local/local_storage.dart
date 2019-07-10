import 'package:shared_preferences/shared_preferences.dart';

///SharedPreferences 本地存储
class LocalStorage {
  static const String ACCOUNT_NUMBER = "account_number";
  static const String USERNAME = "username";
  static const String PASSWORD = "password";

  static save(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  ///删掉单个账号
  static void delUser(LoginUser user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<LoginUser> list = await getUsers();
    list.remove(user);
    saveUsers(list, sp);
  }

  ///保存账号，如果重复，就将最近登录账号放在第一个
  static void saveUser(LoginUser user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<LoginUser> list = await getUsers();
    addNoRepeat(list, user);
    saveUsers(list, sp);
  }

  ///去重并维持次序
  static void addNoRepeat(List<LoginUser> users, LoginUser user) {
    users.removeWhere((item) => item.username == user.username);
    users.insert(0, user);
    if (users.length>5){
      users.removeLast();
    }
  }

  ///获取已经登录的账号列表
  static Future<List<LoginUser>> getUsers() async {
    List<LoginUser> list = new List();
    SharedPreferences sp = await SharedPreferences.getInstance();
    int num = sp.getInt(ACCOUNT_NUMBER) ?? 0;
    for (int i = 0; i < num; i++) {
      String username = sp.getString("$USERNAME$i");
      String password = sp.getString("$PASSWORD$i");
      list.add(LoginUser(username, password));
    }
    return list;
  }

  ///保存账号列表
  static saveUsers(List<LoginUser> users, SharedPreferences sp){
    sp.clear();
    int size = users.length;
    for (int i = 0; i < size; i++) {
      sp.setString("$USERNAME$i", users[i].username);
      sp.setString("$PASSWORD$i", users[i].password);
    }
    sp.setInt(ACCOUNT_NUMBER, size);
  }
}

class LoginUser{
  String username;
  String password;
  LoginUser(this.username,this.password);
}
