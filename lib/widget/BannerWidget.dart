import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Banner extends StatelessWidget{
  final String appId;
  final String bannerId;
  Banner({this.appId,this.bannerId});

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: "banner",
      creationParams: {"appId":appId,"bannerId":bannerId},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}