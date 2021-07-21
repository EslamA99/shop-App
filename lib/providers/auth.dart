import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopApp/models/httpException.dart';

class Auth with ChangeNotifier {
  String token;
  String userId;
  DateTime expireDate;
  Timer timer;

  bool get isAuthenticated {
    return getToken != null;
  }

  get getUserId {
    return userId;
  }

  get getToken {
    if (expireDate != null &&
        expireDate.isAfter(DateTime.now()) &&
        token != null) {
      return token;
    }
    return null;
  }

  Future<void> authenticate(
      String email, String password, String urlWord) async {
    try {
      String url =
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlWord?key=AIzaSyD6esO1QlFkwDdr86HN4AnBx8FdHzEZ3Yc';
      final response = await post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']);
      }
      token = responseData['idToken'];
      userId = responseData['localId'];
      expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      timerLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'userId': userId,
        'expireDate': expireDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> signUp(String email, String password) {
    return authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final userData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>;
    final expDate = DateTime.parse(userData['expireDate']);
    if (expDate.isBefore(DateTime.now())) return false;
    token = userData['token'];
    userId = userData['userId'];
    expireDate = expDate;
    notifyListeners();
    timerLogOut();
    print('object');
    return true;
  }

  void logOut() async {
    token = null;
    expireDate = null;
    userId = null;
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void timerLogOut() {
    if (timer != null) timer.cancel();
    timer = Timer(
        Duration(seconds: expireDate.difference(DateTime.now()).inSeconds),
        logOut);
  }
}
