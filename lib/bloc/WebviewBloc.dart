import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class WebviewBloc extends BlocBase{


  ///状态
  BehaviorSubject<bool> _showAd = BehaviorSubject<bool>();
  Sink<bool> get _showAdSink => _showAd.sink;
  Observable<bool> get showAdStream => _showAd.stream;


  ///是否展示广告
  Future showBanner(bool isShow) async{
    _showAd.add(isShow);
  }
  @override
  void dispose() {
    _showAd?.close();
  }

}