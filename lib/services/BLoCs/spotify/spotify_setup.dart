// add into .env files
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//var clientId = '64fb35e7e6c649508bb1b2511968e045';
var redirectUrl = 'com.spotifyapiexample://callback';

var clientId = "f82f68e26bcb452cbfcd837a5ea2a795";

// this class is used to setup spotify
class SpotifySetup {

  

  static Future<dynamic> getAuthenticationToken() async {
    var playlistData;
    var url = 'https://api.spotify.com/v1/me/playlists?limit=1';
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: clientId,
          redirectUrl: redirectUrl,
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-read-collaborative, '
              'playlist-modify-public,user-read-currently-playing');
      if (authenticationToken != null) {

        NetworkHelper networkHelper = NetworkHelper(url, authenticationToken);

        await networkHelper.getData().then((value) async {
          var data = value['items'][0]['id'];

          var playlistUrl =
              'https://api.spotify.com/v1/playlists/$data?fields=tracks%2Cartists';

          NetworkHelper networkHelper =
              NetworkHelper(playlistUrl, authenticationToken);

          playlistData = await networkHelper.getData();

        });
      }
     return playlistData['tracks']['items'];
    } on PlatformException catch (e) {
    
      print(e.code + '' + e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {

      return Future.error('not implemented');
    }
  }

  static Future<bool> disconnect() async {
    try {
      var result = await SpotifySdk.disconnect();
      return result;
    } on PlatformException catch (e) {
      print(e.code + '' + e.message);
      return false;
    } on MissingPluginException {

      return false;
    }
  }
}

class NetworkHelper {
  NetworkHelper(this.url, this.token);

  final String url;
  final String token;

  Future getData() async {
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
;
    }
  }
}
