import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'JosekiRecord.dart';

const joseki = "assets/joseki.dat";

class Util {
  static List<int> buf = [];

  static String message = "";

  static Future<bool> fileRead() async {
    bool err = false;
    try {
      Future<String> path = loadAssetsFile("joseki.dat");
      message = path as String;
      var file = File(path as String);
      buf = file.readAsBytesSync();
    } catch (e) {
      message += e.toString();
      err = true;
    }
    return err;
  }

  static Future<String> loadAssetsFile(String name) async {
    return rootBundle.loadString('assets/' + name);
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
