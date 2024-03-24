////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {
  
  bool _enableDarkTheme = true;
  bool _useGPU = false;
  bool _isStop = false;

  bool isEditting = false;
  bool isRotating = false;
  
  double _screenPaddngTop = 0.0;
  double _screenPaddngBottom = 0.0;
  double _appBarHeight = 0.0;
  double _navigationBarHeight = 0.0;
  
  int? _predictionDurationMs;

  bool get enableDarkTheme  => _enableDarkTheme;
  bool get useGPU => _useGPU;
  bool get isStop => _isStop;

  int get predictionDurationMs => _predictionDurationMs ?? 0;
  
  double get screenPaddingTop    => _screenPaddngTop;
  double get screenPaddingBottom => _screenPaddngBottom;
  double get appBarHeight        => _appBarHeight;
  double get navigationBarHeight => _navigationBarHeight;

  set enableDarkTheme(bool result) {
    _enableDarkTheme = result;
    notifyListeners();
  }

  set useGPU(bool result) {
    _useGPU = result;
    notifyListeners();
  }

  set isStop(bool result) {
    _isStop = result;
    notifyListeners();
  }

  set predictionDurationMs(int result) {
    _predictionDurationMs = result;
    notifyListeners();
  }

  set screenPaddingTop(double paddingTop) {
    _screenPaddngTop = paddingTop;
    notifyListeners();
  }

  set screenPaddingBottom(double paddingBottom) {
    _screenPaddngBottom = paddingBottom;
    notifyListeners();
  }

  set appBarHeight(double appBarHeight){
    _appBarHeight = appBarHeight;
    notifyListeners();
  }

  set navigationBarHeight(double navigationBarHeight) {
    _navigationBarHeight = navigationBarHeight;
    notifyListeners();
  }

  Future loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _enableDarkTheme = prefs.getBool('enableDarkTheme') ?? true;
    _useGPU = prefs.getBool('useGPU') ?? false;
    _isStop = prefs.getBool('isStop') ?? false;
    notifyListeners();
  }

  Future storePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableDarkTheme', _enableDarkTheme);
    prefs.setBool('useGPU', _useGPU);
    prefs.setBool('isStop', _isStop);
    notifyListeners();
  }
}
