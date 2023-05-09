import 'dart:math';
import 'const.dart';
import 'Goban.dart';

class Tejun {
  int tesu = 0;
  //手順
  List<Point> tejunList = [];
  //取った
  Map<int, List<Point>> toruHash = {};

  //初期化
  void init() {
    tesu = 0;
    tejunList.clear();
    toruHash.clear();
  }

  // 現在の打たれている手数を取得する
  int getTesu() {
    return tesu;
  }

  // 記録されている手数を取得する
  int getKirokuTesu() {
    return tejunList.length;
  }

  // 次の手順に進む
  void next() {
    if (tesu >= tejunList.length) return;
    tesu++;
  }

  // 前の手順に戻る
  void prev() {
    if (tesu <= 0) return;
    tesu--;
  }

  // この手数の石の色を取得する
  int getIsiIro(Goban goban, int tesu) {
    if (tesu % 2 == 0) {
      return SIRO;
    } else {
      return KURO;
    }
  }

  // 今打った石の色を取得する
  int getNowIsiIro(Goban goban) {
    return getIsiIro(goban, tesu);
  }

  // 次に打つ石の色を取得する
  int getNextIsiIro(Goban goban) {
    int isi = getNowIsiIro(goban);
    return isi ^ 3;
  }

  // 今打った石の位置を取得する
  Point getNowLocate() {
    return getLocate(tesu);
  }

  // xx手目の位置を取得する
  Point getLocate(int te) {
    if (te <= 0) {
      return const Point(0, 0);
    }
    return tejunList[te - 1];
  }

  // 今取った石の数を取得する
  int getNowToruSu() {
    int su = 0;
    List<Point> list = getNowToruList();
    su = list.length;
    return su;
  }

  // 削除する
  void delFrom(int te) {
    if (te < 0) return;
    for (int i = te; i <= getKirokuTesu(); i++) {
      toruHash.remove(i + 1);
      tejunList.removeAt(te);
    }
    if (te < tesu) tesu = te;
  }

  // 今打った時の取った石の位置１つを取得する
  Point getNowToruPoint(int i) {
    List<Point> toruList = getToruList(tesu);
    return toruList.elementAt(i);
  }

  // 今取った石のリストを取得する
  List<Point> getNowToruList() {
    return getToruList(tesu);
  }

  // xx手目の取った石のリストを取得する
  List<Point> getToruList(int te) {
    if (toruHash.containsKey(te) == true) {
      List<Point>? toruList = toruHash[te];
      if (toruList != null) {
        return toruList;
      }
    }
    return [];
  }

  // 手順を追加する
  int add(Point p, List<Point> toruList) {
    Point np = Point(p.x, p.y);
    tejunList.add(np);
    int te = tejunList.length;
    if (p.x == 0) return te; //2006-02-02
    if (toruList.isNotEmpty) {
      List<Point> copyList = [...toruList];
      final map1 = <int, List<Point>>{
        te: copyList,
      };
      toruHash.addAll(map1);
    }
    return te;
  }
}
