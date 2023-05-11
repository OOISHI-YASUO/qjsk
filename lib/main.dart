import 'dart:math';
import 'package:flutter/material.dart';
import 'const.dart';
import 'GobanBody.dart';
import 'Goban.dart';
import 'Util.dart';
import 'JosekiRecord.dart';

void main() {
  //runApp(const MyApp());
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Fonts',
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        //primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '定石'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Goban gbn = Goban("main");

  bool pass_view = false;
  String message = "message";

  _MyHomePageState() {
    bool ret = Util.fileRead();
    if (ret as bool) {
      Point bp = Point(10, 10);
      gbn.setStatus(bp, KURO);
      message = Util.getMessage();
      return;
    }
    readKifu(1);
  }

  @override
  //void initState() {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double buttonSize = size.width / 8;
    return Scaffold(
      body: Center(
        child: Wrap(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.horizontal,
          children: <Widget>[
            GestureDetector(
                onTapDown: (details) => onTouchEvent(details),
                onHorizontalDragEnd: (details) =>
                    onSwaipRightLeftEvent(details),
                onVerticalDragEnd: (details) => onSwaipUpDownEvent(details),
                child: GobanBody(gbn)),
            GestureDetector(
              onTapDown: (details) => onTouchEvent2(details),
              child: Row(
                children: <Widget>[
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/undo.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/first.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/prev.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/next.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/last.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/xychg.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: buttonSize,
                    width: buttonSize,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/home.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Visibility(
                    visible: pass_view,
                    child: Container(
                      height: buttonSize,
                      width: buttonSize,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/pass.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(message),
            //adContainer,
          ],
        ),
      ),
    );
  }

  //スワイプ
  void onSwaipUpDownEvent(details) {
    setState(() {
      gbn.changeYJ();
    });
    if (details.primaryVelocity! < 0) {
    } else if (details.primaryVelocity! > 0) {}
  }

  void onSwaipRightLeftEvent(details) {
    setState(() {
      gbn.changeXJ();
    });
    if (details.primaryVelocity! < 0) {
    } else if (details.primaryVelocity! > 0) {}
  }

  void onTouchEvent(details) {
    int isiSize = gbn.isi_size;
    int banLocateX = gbn.ban_locate_x;
    int banLocateY = gbn.ban_locate_y;
    Offset set = details.localPosition;
    int x = set.dx.toInt();
    int y = set.dy.toInt();
    x = x - banLocateX;
    y = y - banLocateY;
    int gx = x ~/ isiSize + 1;
    int gy = y ~/ isiSize + 1;
    if (gx < 1 || gy < 1) return;
    int banSize = gbn.ban_size;
    if (gx > banSize || gy > banSize) return;
    Point bp = Point(gx, gy);
    deside(bp, true);
    setState(() {
      if (gbn.select_pass) {
        pass_view = true;
      } else {
        pass_view = false;
      }
    });
  }

  void onTouchEvent2(details) {
    Size size = MediaQuery.of(context).size;
    double buttonSize = size.width / 8;
    Offset set = details.localPosition;
    int x = set.dx.toInt();
    if (x < buttonSize) {
      setState(() {
        gbn.tejun_prev();
        if (gbn.select_pass) {
          pass_view = true;
        } else {
          pass_view = false;
        }
      });
    } else if (x < buttonSize * 2) {
      setState(() {
        gbn.prevAll();
      });
    } else if (x < buttonSize * 3) {
      setState(() {
        gbn.prev();
      });
    } else if (x < buttonSize * 4) {
      setState(() {
        gbn.next();
      });
    } else if (x < buttonSize * 5) {
      setState(() {
        gbn.nextAll();
      });
    } else if (x < buttonSize * 6) {
      setState(() {
        gbn.changeXY();
      });
    } else if (x < buttonSize * 7) {
      setState(() {
        gbn.nextAll();
        gbn.tejun_first();
        readKifu(1);
      });
    } else if (x < buttonSize * 8) {
      setState(() {
        pass();
      });
    }
  }

  // 棋譜データを読み込む
  void readKifu(int rec) {
    JosekiRecord jr = Util.readRecord(rec);
    while (jr.next_rec > 0 && jr.more_rec == 0) {
      Point bp = Point(jr.x, jr.y);
      deside(bp, false);
      gbn.bangoList.add(bp);
      jr = Util.readRecord(jr.next_rec);
    }
    if (jr.more_rec > 0) {
      gbn.recList_add(jr);
    } else {
      Point bp = Point(jr.x, jr.y);
      deside(bp, false);
      gbn.bangoList.add(bp);
    }
    while (jr.more_rec > 0) {
      jr = Util.readRecord(jr.more_rec);
      gbn.recList_add(jr);
    }
    gbn.is_pass();
    if (gbn.select_pass) {
      pass_view = true;
    } else {
      pass_view = false;
    }

    int tesu = gbn.getTesu();
    List<JosekiRecord> selectList = [...gbn.recList];
    final map1 = <int, List<JosekiRecord>>{tesu: selectList};
    gbn.selectHash.addAll(map1);
  }

  // 手抜きの場合
  void pass() {
    for (int i = 0; i < gbn.recList.length; i++) {
      JosekiRecord jr = gbn.recList.elementAt(i);
      if (jr.x > 10 && jr.y > 10) {
        Point bp = Point(jr.x, jr.y);
        deside(bp, true);
      }
    }
  }

  //ここに決める
  void deside(Point cp, bool choise) {
    Point bp = Point(cp.x, cp.y);
    if (choise) {
      bp = gbn.locateConv2(cp);
    }
    int nextRec = 0;
    //int more_rec = 0;
    if (choise == true) {
      //画面から選択肢を選んだ場合
      bool selected = false;
      for (int i = 0; i < gbn.recList.length; i++) {
        JosekiRecord jr = gbn.recList.elementAt(i);
        if (jr.x == bp.x && jr.y == bp.y) {
          selected = true;
          nextRec = jr.next_rec;
          //more_rec = jr.more_rec;
          break;
        }
      }
      if (selected == false) {
        int sts = gbn.getStatus(cp);
        if (sts == KURO || sts == SIRO) {
          int fTesu = gbn.getThisTesu(cp);
          gbn.bangoList.clear();
          for (int i = fTesu; i <= gbn.getTesu(); i++) {
            Point BL = gbn.getLocate(i);
            gbn.bangoList.add(BL);
          }
        }
        return;
      }
      gbn.recList.clear();
      gbn.bangoList.clear();
    }
    //打つ
    if (gbn.isiUtu(bp) != 0) {
      return;
    }
    if (nextRec > 0) {
      Point ap = Point(bp.x, bp.y);
      gbn.bangoList.add(ap);
      readKifu(nextRec);
    }
  }
}
