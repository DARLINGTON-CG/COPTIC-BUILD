import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager {
  final defaultCacheManager = DefaultCacheManager();

  Future<String> cacheImage(String imagePath) async {
    final Reference ref = FirebaseStorage.instance.refFromURL(imagePath);
    final imageUrl = imagePath;


    if((await defaultCacheManager.getFileFromCache(imageUrl))?.file == null)
    {
      final imageBytes = await ref.getData(10000000);
      await defaultCacheManager.putFile(imageUrl,imageBytes,fileExtension:"jpg");
    } 
    return imageUrl;
  }


}
