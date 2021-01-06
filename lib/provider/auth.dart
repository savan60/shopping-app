import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:fourth/model/httpException.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get user_id {
    return _userId;
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> auth(String email, String password, String urlKey) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlKey?key=AIzaSyCSMeNGe3-ixDQparrq6Njqmgz6-bFwR_w';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final res = json.decode(response.body);
      if (res['error'] != null) {
        throw HttpException(res['error']['message']);
      }
      _token = res['idToken'];
      _userId = res['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            res['expiresIn'],
          ),
        ),
      );
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userdata = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userdata);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async{
    final prefs=await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData=json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate=DateTime.parse(extractedUserData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token=extractedUserData['token'];
    _userId=extractedUserData['userId'];
    _expiryDate=expiryDate;
    notifyListeners();
    _autologout();
    return true;
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timetoexpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoexpire), logout);
  }

  Future<void> signup(String email, String password) async {
    return auth(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return auth(email, password, 'signInWithPassword');
  }
}
