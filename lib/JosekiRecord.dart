class JosekiRecord {
  // 座標
  int x = 0;
  int y = 0;

  // 色
  int col = 0;

  // 次のレコード番号
  int next_rec = 0;

  // 他のレコード番号
  int more_rec = 0;

  JosekiRecord(int wx, int wy, int wcol, int wnext_rec, int wmore_rec) {
    x = wx;
    y = wy;
    col = wcol;
    next_rec = wnext_rec;
    more_rec = wmore_rec;
  }

  void dump() {}
}
