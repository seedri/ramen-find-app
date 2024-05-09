import 'dart:typed_data';
import 'package:image/image.dart' as IMG;

Uint8List resizeImage(Uint8List data, width, height) {
  Uint8List? resizedData = data;
  IMG.Image? img = IMG.decodeImage(data);
  IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
  resizedData = Uint8List.fromList(IMG.encodePng(resized));
  return resizedData;
}
