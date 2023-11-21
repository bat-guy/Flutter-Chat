import 'dart:developer';

class Logger {
  static print(Object e) {
    log(e.toString(), time: DateTime.now());
  }
}
