import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const kURL = 'https://api.sightengine.com/1.0/nudity.json';
const kTextURL = 'https://api.sightengine.com/1.0/text/check.json';

Future<bool> getImageModelationType(String img) async {
  Response response;
  var dio = Dio();

  response = await dio.get(kURL, queryParameters: {
    'url': '$img',
    'api_user': '1074569988',
    'api_secret': 'vnAGv6UJSq7iYD2wPT2t',
  });

  double nude = response.data['nudity']['raw'];

  if (response.statusCode == 200 && nude > 0.8) {
    var data = response.data;

    return true;
  } else {
      return false;
  }
}

Future<List> checkOffensiveText(String text) async {
  Response response;
  var dio = Dio();

  response = await dio.post(kTextURL, queryParameters: {
    'text': '$text',
    'lang': 'en',
    'mode': 'standard',
    'api_user': '1074569988',
    'api_secret': 'vnAGv6UJSq7iYD2wPT2t',
  });

  List textType = response.data['profanity']['matches'];

  if (textType.isNotEmpty) {
    String match = textType[0]['match'];
    String wordType = textType[0]['type'];

    return [true, match, wordType];
  } else {
    return [false, null];
  }
}
