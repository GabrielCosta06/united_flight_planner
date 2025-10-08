import '../data/employee_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple authentication service that uses employee_data.dart as the database
/// and persists the logged-in session using SharedPreferences.
class AuthService {
  // Loads the employee data when an instance is created.
  AuthService() {
    loadEmployeeData();
  }

  // Key used to store the logged-in employee username.
  static const String _sessionKey = 'loggedInUser';

  /// Attempts to log in the user by validating credentials.
  /// If successful, saves the employee's username in SharedPreferences.
  Future<bool> login(String username, String password) async {
    Employee? employee;
    try {
      employee = employees.firstWhere((emp) => emp.username == username);
    } catch (e) {
      employee = null;
    }

    if (employee != null && employee.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, employee.username);
      return true;
    }
    return false;
  }

  /// Checks if there is a logged in user by retrieving the stored session.
  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  /// Clears the saved session, effectively logging out the user.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
