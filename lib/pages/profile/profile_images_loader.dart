import 'dart:convert';
import 'dart:io';

import 'package:copticmeet/pages/profile/utils.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'camera_scan.dart';

class ProfileImagesLoader extends StatefulWidget {
  dynamic data;
  final Database database;

  ProfileImagesLoader({this.data, this.database});

  @override
  _ProfileImagesLoaderState createState() => _ProfileImagesLoaderState();
}

class _ProfileImagesLoaderState extends State<ProfileImagesLoader> {
  Future<List<String>> _buildUrls(String bucket, String path) async {
    var reference = await widget.database.getUserDataOnce();
    var values = await reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
    var order = values["imageOrder"];
    List jsonList = order != null ? json.decode(values["imageOrder"]) : [];
    List<String> urls = [];

    for (int i = 0; i < jsonList.length; i++) {
      int index = i;
      var _url = await FirebaseStorage(storageBucket: '$bucket')
          .ref()
          .child(path + '/' + jsonList[index])
          .getDownloadURL();
      urls.add(_url);
    }
    return urls;
  }

  bool isDownloading = true;
  int done = 0;
  int total = 0;
  String pathh = "";

  String _selectedPath = "";

  bool isEmpty = false;

  void startDownload(String idUser, List<String> urls) async {
    if (urls.isEmpty) {
      setState(() {
        isDownloading = false;
        isEmpty = true;
      });
    }

    HttpClient httpClient = new HttpClient();

    final tempDir = (await getApplicationDocumentsDirectory()).path;
    final imagesDirectory = Directory("$tempDir/$idUser");
    if (imagesDirectory.existsSync()) {
      imagesDirectory.deleteSync(recursive: true);
    }
    imagesDirectory.createSync();

    pathh = "$tempDir/$idUser";

    for (int i = 0; i < urls.length; i++) {
      String _currentUrl = urls[i];
      var request = await httpClient.getUrl(Uri.parse(_currentUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        String filePath = "${imagesDirectory.path}/$i.png";
        File file = File(filePath);
        if (file.existsSync()) file.deleteSync();
        file.createSync();
        await file.writeAsBytes(bytes);
      } else {
        print("Error occured during download: ${response.statusCode}");
      }
    }

    if(mounted)
    setState(() {
      isDownloading = false;
    });
  }

  void start() async {
    final urls = await _buildUrls(
      widget.data['imageBucket'],
      widget.data['imagePath'],
    );
    startDownload(widget.database.userId, urls);
  }

  List<FileSystemEntity> get getFileFromFolder => Directory(pathh).listSync();

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEEEC),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Select image from profile",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      floatingActionButton: _selectedPath.isNotEmpty
          ? ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Theme.of(context).primaryColor;
                  },
                ),
              ),
              onPressed: () async {
                if (_selectedPath != null) {
                  final pr = ProgressDialog(context, isDismissible: false);
                  pr.style(
                    message: '',
                    borderRadius: 10.0,
                    backgroundColor: Colors.white,
                    progressWidget: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    elevation: 10.0,
                    insetAnimCurve: Curves.easeInOut,
                    progress: 0.0,
                    maxProgress: 100.0,
                    progressTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400),
                    messageTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                  await pr.show();
                  final result = await getFacesFromPath(_selectedPath);
                  await pr.hide();
                  int facesCount = result.length;

                  if (facesCount > 0) {
                    if (facesCount == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CameraScan(_selectedPath, widget.database),
                        ),
                      );
                    } else {
                      final snack = SnackBar(
                        content: Text(
                          "Error. More than one face detected.",
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snack);
                    }
                  } else {
                    final snack = SnackBar(
                      content: Text(
                        "Face not detected",
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snack);
                  }

                
                } else {
                  final snack = SnackBar(
                    content: Text(
                      "Image not picked",
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                }
              },
              icon: Icon(
                CupertinoIcons.viewfinder,
              ),
              label: Text(
                "Choose",
              ),
            )
          : SizedBox(),
      body: isDownloading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : (isEmpty
              ? Center(
                  child: Text("No images linked to this profile."),
                )
              : GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  children: List.generate(
                    getFileFromFolder.length,
                    (index) {
                      var element = Directory(pathh).listSync()[index];
                      bool isSelected = _selectedPath == element.path;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPath = element.path;
                          });
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                                new File(
                                  element.path,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )),
    );
  }
}
