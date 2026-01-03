

import 'package:flutter/foundation.dart';


class SelectedDay extends ChangeNotifier {
  String _day = _today();


  String get day => _day;


  void setDay(String newDay) {
    if (_day != newDay) {
      _day = newDay;
      notifyListeners();
    }
  }


  static String _today() {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
    };
    return days[DateTime.now().weekday] ?? 'Monday';
  }
}





