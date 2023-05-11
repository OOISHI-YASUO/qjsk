import 'dart:math';
import 'const.dart';
import 'Tejun.dart';
import 'JosekiRecord.dart';

class Goban {
  String _name = "";

  //碁盤の状態
  List<List<int>> status =
      List.generate(21, (_) => List.generate(21, (_) => 0));

  //手順
  Tejun tjn = Tejun();
  //団子
  List<Point<num>> dngList = [];
  //団子に加えるもの
  List<Point> awdList = [];
  //取り上げるもの
  List<Point> toruList = [];

  //碁盤のサイズ
  int _ban_size = 19;
  //石のサイズ
  int _isi_size = 31;
  int _ban_locate_x = 2;
  int _ban_locate_y = 2;

  String get name => _name;
  int get ban_size => _ban_size;
  int get isi_size => _isi_size;
  int get ban_locate_x => _ban_locate_x;
  int get ban_locate_y => _ban_locate_y;

  //作業領域
  List<List<bool>> cc =
      List.generate(21, (_) => List.generate(21, (_) => false));

  //座標変換
  int xy = 0;
  int xj = 0;
  int yj = 0;

// 定石の選択肢
  List<JosekiRecord> recList = [];

// 手順に対する定石の選択肢
  Map<int, List<JosekiRecord>> selectHash = {};

// 番号表示
  List<Point> bangoList = [];

// パスを選択できる
  bool select_pass = false;

  Goban(String name) {
    _name = name;
  }

  set ban_size(int bansize) {
    _ban_size = bansize;
  }

  set ban_locate_x(int banlocatex) {
    _ban_locate_x = banlocatex;
  }

  set ban_locate_y(int banlocatey) {
    _ban_locate_y = banlocatey;
  }

  set isi_size(int isisize) {
    _isi_size = isisize;
  }

  //次に打つ番の石色は
  int getNextIsiIro() {
    int isi = tjn.getNextIsiIro(this);
    return isi;
  }

  // ＸＹ反転
  void changeXY() {
    if (xy == 0) {
      xy = 1;
    } else {
      xy = 0;
    }
  }

  // 上下反転
  void changeYJ() {
    if (yj == 0) {
      yj = 1;
    } else {
      yj = 0;
    }
  }

  // 左右反転
  void changeXJ() {
    if (xj == 0) {
      xj = 1;
    } else {
      xj = 0;
    }
  }

  // 手数を取得する
  int getTesu() {
    return tjn.getTesu();
  }

  // 記録されている手数を取得する
  int getKirokuTesu() {
    return tjn.getKirokuTesu();
  }

  // xx手目の位置を取得する
  Point getLocate(int te) {
    Point BL = tjn.getLocate(te);
    return BL;
  }

  // この手は何手目か？
  int getThisTesu(Point pt) {
    Point BL;
    for (int i = 1; i <= tjn.getTesu(); i++) {
      BL = tjn.getLocate(i);
      if (BL.x == pt.x && BL.y == pt.y) return i;
    }
    return 0;
  }

  // 座標変換
  Point locateConv(Point bp) {
    Point cp = Point(bp.x, bp.y);
    if (cp.x == 0) return cp;
    if (xy == 0) {
      if (xj == 0 && yj == 1) {
        cp = Point(bp.x, ban_size + 1 - bp.y);
      } else if (xj == 1 && yj == 0) {
        cp = Point(ban_size + 1 - bp.x, bp.y);
      } else if (xj == 1 && yj == 1) {
        cp = Point(ban_size + 1 - bp.x, ban_size + 1 - bp.y);
      }
    } else {
      if (xj == 0 && yj == 0) {
        cp = Point(bp.y, bp.x);
      } else if (xj == 0 && yj == 1) {
        cp = Point(bp.y, ban_size + 1 - bp.x);
      } else if (xj == 1 && yj == 0) {
        cp = Point(ban_size + 1 - bp.y, bp.x);
      } else if (xj == 1 && yj == 1) {
        cp = Point(ban_size + 1 - bp.y, ban_size + 1 - bp.x);
      }
    }
    return cp;
  }

  // 座標変換戻す
  Point locateConv2(Point bp) {
    Point cp = Point(bp.x, bp.y);
    if (cp.x == 0) return cp;
    if (xy == 0) {
      if (xj == 0 && yj == 1) {
        cp = Point(bp.x, ban_size + 1 - bp.y);
      } else if (xj == 1 && yj == 0) {
        cp = Point(ban_size + 1 - bp.x, bp.y);
      } else if (xj == 1 && yj == 1) {
        cp = Point(ban_size + 1 - bp.x, ban_size + 1 - bp.y);
      }
    } else {
      if (xj == 0 && yj == 0) {
        cp = Point(bp.y, bp.x);
      } else if (xj == 0 && yj == 1) {
        cp = Point(bp.y, ban_size + 1 - bp.x);
      } else if (xj == 1 && yj == 0) {
        cp = Point(ban_size + 1 - bp.y, bp.x);
      } else if (xj == 1 && yj == 1) {
        cp = Point(ban_size + 1 - bp.y, ban_size + 1 - bp.x);
      }
    }
    return cp;
  }

  //石を打つ
  int isiUtu(Point p) {
    if (p.x == 0) {
      //パス
      tjn.add(p, toruList);
      next();
      return 0;
    } else {
      int isi = getNextIsiIro();
      int chk = uteruka(isi, p.x.toInt(), p.y.toInt());
      if (chk != 0) return chk;
      tjn.add(p, toruList);
      next();
      return chk;
    }
  }

  // 次に進む
  void next() {
    tjn.next();
    Point BL = getNowLocate();
    if (BL.x == 0) {
      return;
    }
    int isi = getNowIsiIro();
    setStatus(BL, isi);
    List<Point> toruList = tjn.getNowToruList();
    if (toruList.isNotEmpty) {
      for (int i = 0; i < toruList.length; i++) {
        BL = toruList.elementAt(i);
        setStatus(BL, KUU);
      }
    }
    //dump();
  }

  /*
	 * 最終手へ進む
	 */
  void nextAll() {
    int tesu = getTesu();
    int kirokuTesu = getKirokuTesu();
    while (tesu < kirokuTesu) {
      next();
      tesu = getTesu();
    }
  }

  // 前に戻る
  void prev() {
    Point bp = getNowLocate();
    if (bp.x > 0) {
      setStatus(bp, KUU);
      List<Point> toruList = tjn.getNowToruList();
      if (toruList.isNotEmpty) {
        int isi = getNextIsiIro();
        for (int i = 0; i < toruList.length; i++) {
          Point pt = toruList.elementAt(i);
          setStatus(pt, isi);
        }
      }
    }
    tjn.prev();
  }

  // 初手に戻る
  void prevAll() {
    int tesu = getTesu();
    while (tesu > 0) {
      prev();
      tesu = getTesu();
    }
  }

  //今打った石の位置を取得する
  Point getNowLocate() {
    return tjn.getNowLocate();
  }

  //今打った石の色は
  int getNowIsiIro() {
    int isi = tjn.getNowIsiIro(this);
    return isi;
  }

  //この位置の石の状態を取得する
  int getStatusByPoint(Point bp) {
    return getStatusXY(bp.x.toInt(), bp.y.toInt());
  }

  int getStatus(Point bp) {
    return getStatusXY(bp.x.toInt(), bp.y.toInt());
  }

  int getStatusXY(int bx, int by) {
    if (bx < 1 || bx > _ban_size) return HEN;
    if (by < 1 || by > _ban_size) return HEN;
    return status[bx][by];
  }

  void setStatus(Point bp, int isi) {
    status[bp.x.toInt()][bp.y.toInt()] = isi;
  }

  void setStatus2(int bx, int by, int isi) {
    status[bx][by] = isi;
  }

  int uteruka(int isi, int px, int py) {
    if (px == 0) return 0;
    if (getStatusXY(px, py) != KUU) return -1;
    //status[px][py] = isi;
    var wkren = List.generate(
        _ban_size + 2, (_) => List.generate(_ban_size + 2, (_) => false));
    setStatus2(px, py, isi);
    int wisi = isi ^ 3;
    int kuuCnt = 0;
    for (int i = 0; i < 4; i++) {
      if (status[px + addx[i]][py + addy[i]] == KUU) kuuCnt++;
    }
    toruList.clear();
    for (int i = 0; i < 4; i++) {
      int tx = px + addx[i];
      int ty = py + addy[i];
      if (wkren[tx][ty] == true) continue;
      if (status[tx][ty] != wisi) continue;
      createDango(tx, ty);
      if (isDangoToreru() == true) {
        for (int j = 0; j < dngList.length; j++) {
          Point dng = dngList.elementAt(j);
          wkren[dng.x.toInt()][dng.y.toInt()] = true;
          toruList.add(dng);
        }
      }
    }
    if (kuuCnt == 0 && toruList.isEmpty == true) {
      createDango(px, py);
      if (isDangoToreru() == true) {
        setStatus2(px, py, KUU);
        return -2;
      }
    }
    if (kuuCnt == 0 && toruList.length == 1) {
      int tesu = tjn.getTesu();
      if (tesu > 1) {
        Point np = tjn.getNowLocate();
        Point tp = toruList.elementAt(0);
        if (np.x == tp.x && np.y == tp.y) {
          if (tjn.getNowToruSu() == 1) {
            np = tjn.getNowToruPoint(0);
            if (px == np.x && py == np.y) {
              setStatus2(px, py, KUU);
              return -3;
            }
          }
        }
      }
    }
    setStatus2(px, py, KUU);
    return 0;
  }

  // 石の固まりを作る
  void createDango(int x, int y) {
    for (int cy = 0; cy <= ban_size; cy++) {
      for (int cx = 0; cx <= ban_size; cx++) {
        cc[cx][cy] = false;
      }
    }
    dngList.clear();
    Point p = Point(x, y);
    dngList.add(p);
    cc[x][y] = true;
    int newPtr = 0;
    int newCnt = 1;
    while (newCnt > 0) {
      awdList.clear();
      for (int n = newPtr; n < newPtr + newCnt; n++) {
        Point dng1 = dngList.elementAt(n);
        for (int i = 0; i < 4; i++) {
          addAwd(dng1.x.toInt(), dng1.y.toInt(), addx[i], addy[i]);
        }
      }
      if (awdList.isNotEmpty) {
        newPtr += newCnt;
        for (int i = 0; i < awdList.length; i++) {
          Point dng = awdList.elementAt(i);
          dngList.add(dng);
        }
      }
      newCnt = awdList.length;
    }
  }

  // 同じ石だったら加える
  void addAwd(int cx, int cy, int ax, int ay) {
    int px = cx + ax;
    int py = cy + ay;
    int stsp = getStatusXY(px, py);
    if (stsp == HEN) return;
    if (cc[px][py] == true) return;
    cc[px][py] = true;
    if (getStatusXY(cx, cy) != getStatusXY(px, py)) return;
    awdList.add(Point(px, py));
  }

  // この連は取れる状態なのか？
  bool isDangoToreru() {
    for (int i = 0; i < dngList.length; i++) {
      Point dng = dngList.elementAt(i);
      for (int j = 0; j < 4; j++) {
        int x = dng.x.toInt() + addx[j];
        int y = dng.y.toInt() + addy[j];
        if (status[x][y] == KUU) return false;
      }
    }
    return true;
  }

  //選択肢追加
  void recList_add(JosekiRecord jr) {
    recList.add(jr);
    if (jr.x > 10 && jr.y > 10) {
      select_pass = true;
    } else {
      select_pass = false;
    }
  }

  //パスがあるかどうかの判定
  void is_pass() {
    select_pass = false;
    for (int i = 0; i < recList.length; i++) {
      JosekiRecord jr = recList.elementAt(i);
      if (jr.x > 10 && jr.y > 10) {
        select_pass = true;
        break;
      }
    }
  }

  // 前の手順に戻る
  void tejun_prev() {
    int tesu = getTesu();
    if (tesu <= 0) return;
    int kirokuTesu = getKirokuTesu();
    if (tesu != kirokuTesu) return;
    bangoList.clear();
    selectHash.remove(tesu);
    recList.clear();
    while (recList.isEmpty) {
      prev();
      tjn.delFrom(tesu - 1);
      tesu = tjn.getTesu();
      selectHash.forEach((te, selectList) {
        if (te == tesu) {
          recList = [...selectList];
        }
      });
      if (tesu == 0) break;
    }
    is_pass();
  }

  // 最初の手順に戻る
  void tejun_first() {
    int tesu = getTesu();
    if (tesu <= 0) return;
    int kirokuTesu = getKirokuTesu();
    if (tesu != kirokuTesu) return;
    bangoList.clear();
    selectHash.remove(tesu);
    recList.clear();
    while (tesu > 0) {
      prev();
      tjn.delFrom(tesu - 1);
      tesu = getTesu();
    }
  }
}
