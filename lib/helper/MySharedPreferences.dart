import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static MySharedPreferences? _instance;
  SharedPreferences? _prefs;

  String? customerId;
  bool isUserSignedIn = false;

  MySharedPreferences._();

  factory MySharedPreferences.getInstance() {
    _instance ??= MySharedPreferences._();
    return _instance!;
  }

  Future getCustomerId() async {
    _prefs = await SharedPreferences.getInstance();
    customerId = _prefs!.getString("customerId");
  }

  Future isSignedIn() async {
    _prefs = await SharedPreferences.getInstance();
    isUserSignedIn = _prefs!.getBool("isSignedIn") ?? false;
  }
}
