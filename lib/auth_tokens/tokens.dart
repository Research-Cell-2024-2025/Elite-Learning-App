import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

const _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

Future<String> getAccessToken() async {
  try {
    final serviceAccount = json.decode(await rootBundle.loadString('assets/service-account.json'));
    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);

    final authClient = await clientViaServiceAccount(accountCredentials, _scopes);
    final accessToken = authClient.credentials.accessToken.data;
    authClient.close();

    return accessToken;
  } catch (e) {
    print('Failed to get access token: $e');
    rethrow;
  }
}
