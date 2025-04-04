import 'dart:convert';

import 'package:fcx_app/local_db/sqlite_db_helper.dart';
import 'package:fcx_app/remote_db/remote_utils.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ProfileRepository {
  Future<Uri?> _getProfileUrl() async {
    Map<String, dynamic>? user = await DBHelper().getUser();

    if (user != null) {
      String id = user['id'];
      String url = '$BASEURL/api/users/$id';

      Logger().d(url);
      return Uri.parse(url);
    }

    return null;
  }

  Future<http.Response?> httpGetProfile() async {
    Uri? profileUrl = await _getProfileUrl();

    if (profileUrl != null) {
      final response = await http.get(
        profileUrl,
        headers: {'Content-Type': 'application/json'},
      );

      Logger().e(response.body);

      return response;
    }

    return null;
  }

  Future<http.Response?> httpUpdateProfile(Map<String, dynamic> payload) async {
    Uri? profileUrl = await _getProfileUrl();

    if (profileUrl != null) {
      final response = await http.put(
        profileUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      Logger().e(response.body);

      return response;
    }

    return null;
  }
}
