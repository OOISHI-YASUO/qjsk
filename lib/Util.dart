import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'JosekiRecord.dart';

class Util {
  static List<int> buf = [];

  static String message = "";

  static Future fileRead() async {
    try {
      final File file = await getImageFileFromAssets("joseki.dat");
      buf = file.readAsBytesSync();
    } catch (e) {
      message += e.toString();
    }
  }

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file =
        File('${(await getApplicationDocumentsDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  static String getMessage() {
    return message;
  }

  static JosekiRecord readRecord(int rec) {
    int inx = rec * 12;
    int x = buf[inx++];
    int y = buf[inx++];
    int col = buf[inx++];
    inx++;
    int firstByte = buf[inx++];
    int secondByte = buf[inx++];
    int thirdByte = buf[inx++];
    int fourthByte = buf[inx++];
    int nextRec =
        ((firstByte | secondByte << 8 | thirdByte << 16 | fourthByte << 24));
    firstByte = buf[inx++];
    secondByte = buf[inx++];
    thirdByte = buf[inx++];
    fourthByte = buf[inx++];
    int moreRec =
        ((firstByte | secondByte << 8 | thirdByte << 16 | fourthByte << 24));
    return JosekiRecord(x, y, col, nextRec, moreRec);
  }

  static void setPositionSync(int i) {}
}
