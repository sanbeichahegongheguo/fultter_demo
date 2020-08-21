import 'dart:async';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class InappPurchase {
  StreamSubscription purchaseUpdatedSubscription;
  StreamSubscription purchaseErrorSubscription;
  StreamSubscription conectionSubscription;

  init() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('InappPurchase result: $result');
  }

  pay(String productId) async{
    await FlutterInappPurchase.instance.requestPurchase(productId);
  }

  close() async {
    await FlutterInappPurchase.instance.endConnection;
    purchaseUpdatedSubscription?.cancel();
    purchaseUpdatedSubscription = null;
    purchaseErrorSubscription?.cancel();
    purchaseErrorSubscription = null;
    conectionSubscription?.cancel();
    conectionSubscription = null;
  }
}
