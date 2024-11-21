import 'package:flutter/material.dart';
import '../models/background_option.dart';

class BackgroundController extends ChangeNotifier {
  int _selectedIndex;
  final List<BackgroundOption> options;

  BackgroundController({
    required this.options,
    int initialIndex = 0,
  }) : _selectedIndex = initialIndex;

  int get selectedIndex => _selectedIndex;
  BackgroundOption get currentBackground => options[_selectedIndex];

  void setBackground(int index) {
    if (index >= 0 && index < options.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
