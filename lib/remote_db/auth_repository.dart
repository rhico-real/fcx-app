import 'dart:convert';

import 'package:fcx_app/local_db/sqlite_db_helper.dart';
import 'package:fcx_app/remote_db/remote_utils.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthRepository {
  var loginUrl = Uri.parse('$BASEURL/api/auth/login');
  var registerUrl = Uri.parse('$BASEURL/api/auth/register');

  Future<http.Response> httpLogin(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final statusCode = response.statusCode;
      final responseBody = response.body;

      Logger().i('Response ($statusCode): $responseBody');

      if (statusCode == 200) {
        final decoded = jsonDecode(responseBody);

        if (decoded['user'] != null) {
          final user = decoded['user'];

          await DBHelper().clearUser();
          await DBHelper().insertUser({
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
          });

          Logger().i('User saved: ${user['name']}');
        } else {
          Logger().w('No user found in response');
        }
      } else {
        Logger().w('Login failed with status: $statusCode');
      }

      return response;
    } catch (e, stacktrace) {
      Logger().e('Login error', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<http.Response> httpRegister(Map<String, dynamic> payload) async {
    final response = await http.post(
      registerUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    Logger().e(response.body);

    return response;
  }
}
