

abstract class BlocBase {
  ///请求next，是否有网络
  doNext(sink,res) async {
    if (res.next != null) {
      var resNext = await res.next;
      if (resNext != null && resNext.result) {
        sink?.add(resNext.data);
      }
    }
  }
  void dispose();
}