import 'dart:convert';

class Employee {
  final String employeeId;
  String name;
  String username;
  String email;
  String password;
  String abbreviatedName;
  String abbreviatedName2;
  String profileImagePath;
  String passType;

  Employee({
    required this.employeeId,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.abbreviatedName,
    required this.abbreviatedName2,
    required this.profileImagePath,
    required this.passType,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? '', // load password from JSON
      abbreviatedName: json['abbreviatedName'] ?? '',
      abbreviatedName2: json['abbreviatedName2'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      passType: json['passType'] ?? '', // load passType from JSON
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'name': name,
        'username': username,
        'email': email,
        'password': password, // include password in JSON output
        'abbreviatedName': abbreviatedName,
        'abbreviatedName2': abbreviatedName2,
        'profileImagePath': profileImagePath,
        'passType': passType, // include passType in JSON output
      };
}

// Simulated persistent data stored in JSON format.
final String employeeDataJson = '''
{
  "employees": [
    {
      "employeeId": "427776",
      "passType": "SA1P24",
      "name": "Rafael de Lima Santos Costa",
      "username": "rafael.costa",
      "email": "rafael.costa@united.com",
      "abbreviatedName": "COSTA, R.",
      "abbreviatedName2": "Costa Rafael",
      "password": "123",
      "profileImagePath": ""
    }
  ]
}
''';

List<Employee> employees = [];

// Loads employee data from the JSON string.
void loadEmployeeData() {
  final Map<String, dynamic> data = json.decode(employeeDataJson);
  employees =
      (data['employees'] as List).map((e) => Employee.fromJson(e)).toList();
}

// Updates the employee record in memory by matching the username.
void updateEmployeeProfileImage(String username, String newPath) {
  for (var emp in employees) {
    if (emp.username == username) {
      // Compare with username instead of employeeId
      emp.profileImagePath = newPath;
      break;
    }
  }
}
