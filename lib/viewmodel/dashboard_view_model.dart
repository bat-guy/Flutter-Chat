import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/services/database.dart';

class DashboardViewModel {
  late DatabaseService _dbService;
  final UserCred _user;

  DashboardViewModel(this._user) {
    _dbService = DatabaseService(uid: _user.uid);
  }

  Future<List<UserProfile>> getUserList() async {
    return await _dbService.getUserList(_user.uid);
  }
}
