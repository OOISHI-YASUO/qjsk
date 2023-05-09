import 'dart:io';
import 'JosekiRecord.dart';

//final joseki = "assets/test.txt";
final joseki = "assets/joseki.dat";

class Util {
  static List<int> buf = [];

  static void fileRead() {
    var file = File(joseki);
    buf = file.readAsBytesSync();
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
    int next_rec =
        ((firstByte | secondByte << 8 | thirdByte << 16 | fourthByte << 24));
    firstByte = buf[inx++];
    secondByte = buf[inx++];
    thirdByte = buf[inx++];
    fourthByte = buf[inx++];
    int more_rec =
        ((firstByte | secondByte << 8 | thirdByte << 16 | fourthByte << 24));
    return JosekiRecord(x, y, col, next_rec, more_rec);
  }

  static void setPositionSync(int i) {}
}
