import 'package:flutter/material.dart';
import '../models/church_model.dart';

class ChurchProvider with ChangeNotifier {
  List<Church> _churches = [];

  List<Church> get churches => _churches;

  void setChurches(List<Church> churchesList) {
    _churches = churchesList;
    notifyListeners();
  }
}
