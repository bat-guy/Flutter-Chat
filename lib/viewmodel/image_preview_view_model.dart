import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImagePreviewViewModel {
  final _messageLoaderProvidor = StreamController<bool>();
  Stream<bool> get messageLoaderStream => _messageLoaderProvidor.stream;

  downloadImage(String imgUrl) async {
    _messageLoaderProvidor.add(true);
    var response = await http.get(Uri.parse(imgUrl));
    final documentDirectory = await getDownloadsDirectory();
    File file = File(join(documentDirectory!.path, 'imagetest.png'));
    file.writeAsBytesSync(response.bodyBytes);
    _messageLoaderProvidor.add(false);
  }
}
