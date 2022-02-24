import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DownloadProvider extends ChangeNotifier {
  int _done = 0;
  int _total = 0;

  bool get isDownloading => _done < _total;

  double get percent => ((_done * 100) / (_total));


}
