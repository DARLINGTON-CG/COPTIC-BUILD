import 'package:geolocator/geolocator.dart';

abstract class Location {
  Future calculateDistance(String startUser, String endUser);
}

class GeolocatorLocation implements Location {
  Future calculateDistance(String startUser, String endUser) async {
    if (startUser == null ||
        startUser?.length == 0 ||
        endUser == null ||
        endUser.length == 0) {
      return 0;
    }

    List _startUserList = startUser.split(',');
    List _endUserList = endUser.split(',');

    var _distance = await Geolocator().distanceBetween(
        double.parse(_startUserList[0]),
        double.parse(_startUserList[1]),
        double.parse(_endUserList[0]),
        double.parse(_endUserList[1]));

    return _distance;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
