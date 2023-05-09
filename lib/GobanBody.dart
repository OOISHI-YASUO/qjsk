import 'dart:math';
import 'package:flutter/material.dart';
import 'const.dart';
import 'JosekiRecord.dart';
import 'Goban.dart';
//import 'Util.dart';

/*
	 * 拡大に関する定義
	 */
final int ZOOM_NONE = 0;
final int ZOOM_LEFT_UP = 1;
final int ZOOM_LEFT_DOWN = 2;
final int ZOOM_RIGHT_UP = 3;
final int ZOOM_RIGHT_DOWN = 4;

int button_height = 80;

// ignore: must_be_immutable
class GobanBody extends StatelessWidget {
  Goban gbn = Goban("GobanBody");

  GobanBody(goban) {
    gbn = goban;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    button_height = (size.width / 8).toInt();
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(246, 168, 104, 1),
      ),
      width: size.width,
      height: size.height - button_height,
      child: CustomPaint(
        painter: _GobanPainter(gbn, size),
      ),
    );
  }
}

//碁盤を描く
class _GobanPainter extends CustomPainter {
  int zoom_mode = ZOOM_LEFT_UP;

  int isi_size = 31;
  int isi_half = 16;
  int isi_quarter = 8;
  int isi_8 = 4;
  int ban_size = 19;
  int ban_width = 0;

  int ban_locate_x = 2;
  int ban_locate_y = 2;

  int ban_locate_x_default = 0;
  int ban_locate_y_default = 0;

  // 画面のサイズ
  int screen_width = 0;
  int screen_height = 0;

  //文字の数字
  String su_str = "";

  Goban gbn = Goban("_GobanPainter");

  _GobanPainter(Goban goban, Size size) {
    gbn = goban;
    ban_size = gbn.ban_size;
    screen_width = size.width.toInt();
    screen_height = size.height.toInt() - button_height;
    isi_size = (screen_width / 12).toInt();
    gbn.isi_size = isi_size;
    isi_half = (isi_size / 2).floor();
    isi_quarter = (isi_size / 4).floor();
    isi_8 = (isi_size / 8).floor();
    ban_width = isi_size * ban_size;
    gbn.ban_locate_x = ban_locate_x;
    gbn.ban_locate_y = ban_locate_y;
    zoom(ZOOM_RIGHT_UP);
    setZoomMode();
  }

  @override
  void paint(Canvas canvas, Size size) {
    screen_height = size.height.toInt() - button_height;
    ban_size = gbn.ban_size;
    //int ban_length = isi_size * ban_size;
    final paint = Paint()..color = Colors.black;
    double x1 = ban_locate_x + isi_half - 1;
    double x2 = x1 + (ban_size - 1) * isi_size;
    for (int y = 0; y < ban_size; y++) {
      double yy = ban_locate_y + y * isi_size + isi_half - 1;
      if (yy < size.height) {
        canvas.drawLine(Offset(x1, yy), Offset(x2, yy), paint);
      }
    }
    double y1 = ban_locate_y + isi_half - 1;
    double y2 = y1 + (ban_size - 1) * isi_size;
    if (y2 > size.height) y2 = size.height;
    for (int x = 0; x < ban_size; x++) {
      double xx = ban_locate_x + x * isi_size + isi_half - 1;
      canvas.drawLine(Offset(xx, y1), Offset(xx, y2), paint);
    }
    int st = 4;
    int ad = 6;
    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        drawHosi(canvas, x * ad + st, y * ad + st);
      }
    }
    for (int y = 1; y <= ban_size; y++) {
      for (int x = 1; x <= ban_size; x++) {
        int sts = gbn.getStatusXY(x, y);
        if (sts == 0) continue;
        Point bp = Point(x, y);
        drawIsi(canvas, bp, sts);
      }
    }

    //選択肢をマークする
    showSelectMark(canvas);
    //番号を表示する
    showBango(canvas);
    int tesu = gbn.getTesu();
    int kiroku_tesu = gbn.getKirokuTesu();
    if (tesu < kiroku_tesu) {
      showMark(canvas);
    }
  }

  // 現在手番をマークする
  void showMark(Canvas canvas) {
    Point bp = gbn.getNowLocate();
    Point p = gbn.locateConv(bp);
    drawSelectMark(canvas, p, 0);
  }

  // 石を描く
  void drawIsi(Canvas canvas, Point bp, int col) {
    Point p = gbn.locateConv(bp);
    if (p.x == 0) return;
    int px = (ban_locate_x + (p.x - 1) * isi_size + isi_half).toInt();
    int py = (ban_locate_y + (p.y - 1) * isi_size + isi_half).toInt();
    final paint = Paint();
    if (col == KURO) {
      paint.color = Colors.black;
    } else {
      paint.color = Colors.white;
    }

    double x = px.toDouble();
    double y = py.toDouble();
    double r = isi_half.toDouble();

    canvas.drawCircle(Offset(x, y), r, paint);

    final line = Paint();

    line.color = Colors.blue;
    line.strokeCap = StrokeCap.round;
    line.style = PaintingStyle.stroke;
    line.strokeWidth = 1;
    canvas.drawCircle(Offset(x, y), r, line);
  }

  // 選択肢をマークする
  void showSelectMark(Canvas canvas) {
    if (gbn.recList.isEmpty) return;
    int tesu = gbn.tjn.tesu;
    int kiroku_tesu = gbn.getKirokuTesu();
    if (tesu < kiroku_tesu) return;
    gbn.select_pass = false;
    for (int i = 0; i < gbn.recList.length; i++) {
      JosekiRecord jr = gbn.recList.elementAt(i);
      if (jr.x == 0) {
        gbn.select_pass = true;
      } else {
        Point bp = Point(jr.x, jr.y);
        drawSelectMark(canvas, bp, jr.col);
      }
    }
  }

  // 選択肢をマークする
  void drawSelectMark(Canvas canvas, Point bp, int col) {
    if (bp.x <= 0) return;
    Point p = gbn.locateConv(bp);
    if (p.x == 0) return;
    int bx = p.x.toInt();
    int by = p.y.toInt();
    var paint = Paint()..color = Colors.black;
    if (col == 0) {
      paint.color = Colors.lightBlue;
    } else if (col == 1) {
      paint.color = Colors.red;
    } else if (col == 2) {
      paint.color = Colors.blue;
    } else if (col == 3) {
      paint.color = Colors.yellow;
    } else if (col == 4) {
      paint.color = Colors.green;
    }
    int r = (isi_size / 6).toInt();
    int x1 = ban_locate_x + (bx - 1) * isi_size + isi_half;
    int y1 = ban_locate_y + (by - 1) * isi_size + isi_half;
    double dx1 = (x1 - r).toDouble();
    double dy1 = (y1 - r).toDouble();
    canvas.drawRect(Rect.fromLTWH(dx1, dy1, r * 2, r * 2), paint);
  }

  /*
	 * 番号を表示する
	 */
  void showBango(Canvas canvas) {
    List<List<bool>> cc =
        List.generate(21, (_) => List.generate(21, (_) => false));

    int tesu = gbn.getTesu();
    int kiroku_tesu = gbn.getKirokuTesu();
    if (tesu == kiroku_tesu && gbn.bangoList.isNotEmpty) {
      if (gbn.bangoList.length >= 2) {
        for (int i = 0; i < gbn.bangoList.length; i++) {
          Point bp = gbn.bangoList.elementAt(i);
          if (cc[bp.x.toInt()][bp.y.toInt()] == true) continue;
          drawBango(canvas, bp, i + 1);
          cc[bp.x.toInt()][bp.y.toInt()] = true;
        }
      }
    }
  }

  // 番号を描く
  void drawBango(Canvas canvas, Point bp, int su) {
    double font_size = isi_half.toDouble();
    var textStyleB = TextStyle(
      color: Colors.black,
      fontSize: font_size,
    );
    var textStyleW = TextStyle(
      color: Colors.white,
      fontSize: font_size,
    );
    final TextPainter textPainterB = TextPainter(
        text: TextSpan(text: su_str, style: textStyleB),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    final TextPainter textPainterW = TextPainter(
        text: TextSpan(text: su_str, style: textStyleW),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    textPainterB.layout(
      minWidth: 0,
      maxWidth: 50,
    );
    textPainterW.layout(
      minWidth: 0,
      maxWidth: 50,
    );

    if (bp.x == 0) return;
    if (zoom_mode == ZOOM_NONE) return;
    int sts = gbn.getStatus(bp);
    if (sts == 0) return;
    Point p = gbn.locateConv(bp);
    if (p.x == 0) return;
    su_str = su.toString();
    double px = (ban_locate_x + (p.x - 1) * isi_size).toDouble();
    double py = (ban_locate_y + (p.y - 1) * isi_size).toDouble();
    if (su < 10) {
      px += isi_quarter + isi_8;
      py += isi_8;
    } else {
      px += isi_quarter;
      py += isi_8;
    }

    var offset = Offset(px, py);
    if (sts == KURO) {
      textPainterW.paint(canvas, offset);
    } else {
      textPainterB.paint(canvas, offset);
    }
  }

  void drawHosi(Canvas canvas, int x, int y) {
    final paint = Paint()..color = Colors.black;
    double r = isi_half / 8;
    double d = isi_half / 4 - 1;
    if (r < 3) r = 3;
    if (d < 4) d = 4;
    double x1 = ban_locate_x + (x - 1) * isi_size + isi_half - r;
    double y1 = ban_locate_y + (y - 1) * isi_size + isi_half - r;
    canvas.drawRect(Rect.fromLTWH(x1, y1, d, d), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // 拡大する
  void zoom(int zoom_mode) {
    //碁石と碁盤の大きさを決める
    ban_width = ban_size * isi_size;
    //碁盤の位置を決める
    if (zoom_mode == ZOOM_NONE || zoom_mode == ZOOM_LEFT_UP) {
      ban_locate_x = ban_locate_x_default;
      ban_locate_y = ban_locate_y_default;
    } else if (zoom_mode == ZOOM_RIGHT_UP) {
      ban_locate_x = ban_locate_x_default + screen_width - ban_width;
      ban_locate_y = ban_locate_y_default;
    } else if (zoom_mode == ZOOM_LEFT_DOWN) {
      ban_locate_x = ban_locate_x_default;
      ban_locate_y = ban_locate_y_default + screen_height - ban_width;
    } else if (zoom_mode == ZOOM_RIGHT_DOWN) {
      ban_locate_x = ban_locate_x_default + screen_width - ban_width;
      ban_locate_y = ban_locate_y_default + screen_height - ban_width;
    }
  }

  void setZoomMode() {
    int xj = gbn.xj;
    int yj = gbn.yj;
    if (xj == 0) {
      if (yj == 0) {
        zoom(ZOOM_LEFT_UP);
      } else {
        zoom(ZOOM_LEFT_DOWN);
      }
    } else {
      if (yj == 0) {
        zoom(ZOOM_RIGHT_UP);
      } else {
        zoom(ZOOM_RIGHT_DOWN);
      }
    }
  }

  // 上下入れ替え
  void changeYJ() {
    gbn.changeYJ();
    if (zoom_mode == ZOOM_LEFT_DOWN)
      zoom(ZOOM_LEFT_UP);
    else if (zoom_mode == ZOOM_LEFT_UP)
      zoom(ZOOM_LEFT_DOWN);
    else if (zoom_mode == ZOOM_RIGHT_DOWN)
      zoom(ZOOM_RIGHT_UP);
    else if (zoom_mode == ZOOM_RIGHT_UP) zoom(ZOOM_RIGHT_DOWN);
  }

  // 左右入れ替え
  void changeXJ() {
    gbn.changeXJ();
    if (zoom_mode == ZOOM_LEFT_DOWN)
      zoom(ZOOM_RIGHT_DOWN);
    else if (zoom_mode == ZOOM_RIGHT_DOWN)
      zoom(ZOOM_LEFT_DOWN);
    else if (zoom_mode == ZOOM_LEFT_UP)
      zoom(ZOOM_RIGHT_UP);
    else if (zoom_mode == ZOOM_RIGHT_UP) zoom(ZOOM_LEFT_UP);
  }
}
