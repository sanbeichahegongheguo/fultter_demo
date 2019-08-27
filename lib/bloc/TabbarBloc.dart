import 'package:rxdart/rxdart.dart';

import 'BlocBase.dart';

class TabbarBloc extends BlocBase{

  ///页面
  BehaviorSubject<int> _tabbarBanner = BehaviorSubject<int>();
  Sink<int> get _tabbarBannerSink => _tabbarBanner.sink;
  Observable<int> get tabbarBannerStream => _tabbarBanner.stream;


  ///切换页面
  Future callTab(int page) async{
    _tabbarBannerSink.add(page);
  }
  @override
  void dispose() {
    _tabbarBanner.close();
  }

}