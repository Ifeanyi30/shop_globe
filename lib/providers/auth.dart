import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_globe/models/exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String _email;
  Timer _authTimer;

  bool get isAuth {
    return _token != null &&
        (_expiryDate != null && _expiryDate.isAfter(DateTime.now()));
  }

  String get userEmail {
    return _email ?? '';
  }

  String get matchEmail {
    RegExp regExp = RegExp(r"(^[a-zA-Z0-9]+)");
    return toBeginningOfSentenceCase(regExp.stringMatch(_email));
  }

  String get token {
    return isAuth ? _token : '';
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlString) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlString?key=AIzaSyB2JkNm0G46a6XRmOwU5kz1WkxNLz3dxyQ');

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
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _email = responseData['email'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    const signUpStr = 'signUp';
    return _authenticate(email, password, signUpStr);
  }

  Future<void> login(String email, String password) async {
    const loginStr = 'signInWithPassword';
    return _authenticate(email, password, loginStr);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('userData is false');
      return false;
    }
    final extraUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, Object>;
    final expiryDate = DateTime.parse(extraUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      print('expiryDate expired');
      return false;
    }

    print('token still valid');
    _token = extraUserData['token'] as String;
    _userId = extraUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); to remove one key-value pair from storage.
    prefs.clear(); // or use this to clear all app data in device storage.
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExp = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExp), logout);
  }
}
