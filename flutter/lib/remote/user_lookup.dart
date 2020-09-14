import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

FirebaseOptions _opts;

Future<String> userLookup(String email) async {
  _opts ??= Firebase.app().options;
  final uri = Uri(
      scheme: 'https',
      host: 'us-central1-${_opts.projectId}.cloudfunctions.net',
      path: 'userLookup',
      queryParameters: <String, dynamic>{'q': email});

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    return response.body;
  }
  if (response.statusCode == 404) {
    return null;
  }
  throw HttpException('User lookup failed: ${response.statusCode}');
}
