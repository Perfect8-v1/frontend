import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient();
  bool _loggedIn = false;
  String? _email;

  bool get isLoggedIn => _loggedIn;
  String? get email => _email;

  Future<bool> login(String email, String password) async {
    final ok = await _api.login(email, password);
    _loggedIn = ok;
    if (ok) _email = email;
    notifyListeners();
    return ok;
  }

  void logout() {
    _loggedIn = false;
    _email = null;
    notifyListeners();
  }
}
