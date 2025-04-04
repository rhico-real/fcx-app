import 'dart:convert';

import 'package:fcx_app/remote_db/remote_utils.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AdminRepository {
  var adminUrl = Uri.parse('$BASEURL/api/users');

  Future<http.Response?> httpGetUsers() async {
    final response = await http.get(
      adminUrl,
      headers: {'Content-Type': 'application/json'},
    );

    Logger().e(response.body);

    return response;
  }

  Future<http.Response?> httpUpdateProfile(
    Map<String, dynamic> payload,
    String userId,
  ) async {
    final url = Uri.parse('$BASEURL/api/users/$userId');
    Logger().e(url);

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    Logger().e(response.body);

    return response;
  }

  Future<http.Response?> httpDeleteProfile(String userId) async {
    final url = Uri.parse('$BASEURL/api/users/$userId');
    Logger().e(url);

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    Logger().e(response.body);

    return response;
  }
}
