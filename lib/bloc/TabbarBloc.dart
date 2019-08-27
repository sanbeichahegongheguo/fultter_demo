import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class TabbarBloc extends BlocBase{

  ///页面
  PublishSubject<int> _tabbarBanner = PublishSubject<int>();
  Sink<int> get _tabbarBannerSink => _tabbarBanner.sink;
  Observable<int> get tabbarBannerStream => _tabbarBanner.stream;


  ///是否展示广告
  Future callTab(int page) async{
    _tabbarBannerSink.add(page);
  }
  @override
  void dispose() {
    _tabbarBanner.close();
  }

}