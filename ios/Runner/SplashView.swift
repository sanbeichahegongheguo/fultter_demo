//
//  SplashViewController.swift
//  GDTMobSample-Swift
//
//  Created by nimomeng on 2018/8/15.
//  Copyright © 2018 Tencent. All rights reserved.
//

class SplashView: NSObject, FlutterPlatformView,GDTSplashAdDelegate {
    let viewId:Int64
    let withFrame:CGRect
    let controller: UIViewController
    let channel:FlutterMethodChannel
    let messenger:FlutterBinaryMessenger
    private var splashAd: GDTSplashAd!
    private var bottomView: UIView!
    private var _view: UIView!
    init(withFrame: CGRect, viewId: Int64, args: Any?, controller:
        UIViewController,messenger:FlutterBinaryMessenger){
        self.withFrame = withFrame
        self.viewId = viewId
        self.controller = controller
        self.messenger = messenger
        self.channel = FlutterMethodChannel(name: "splash_"+String(viewId),binaryMessenger: messenger)
        splashAd = GDTSplashAd.init(appId: "1106430707", placementId: "9020920731199709")
        splashAd.fetchDelay = 5
        bottomView = UIView.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height * 0.25)))
        _view = UIView.init(frame:withFrame)
        bottomView.backgroundColor = .white
        let window = UIApplication.shared.keyWindow
        splashAd.loadAndShow(in: window, withBottomView: nil, skip: nil)
        super.init()
        splashAd.delegate = self
    }
    
    func view() -> UIView {
        return _view;
    }
    
    func splashAdSuccessPresentScreen(_ splashAd: GDTSplashAd!) {
        self.channel.invokeMethod("show", arguments: nil)
        print("开屏广告成功展示")
    }
    
    func splashAdFail(toPresent splashAd: GDTSplashAd!, withError error: Error!) {
         self.channel.invokeMethod("error", arguments: nil)
        print(#function,error)
    }
    
    func splashAdExposured(_ splashAd: GDTSplashAd!) {
        print("开屏广告曝光回调!!")
    }
    
    func splashAdClicked(_ splashAd: GDTSplashAd!) {
        print("开屏广告点击回调!!")
    }
    
    func splashAdApplicationWillEnterBackground(_ splashAd: GDTSplashAd!) {
        print("当点击下载应用时会调用系统程序打开，应用切换到后台")
    }
    
    func splashAdWillClosed(_ splashAd: GDTSplashAd!) {
        print("开屏广告将要关闭回调!!")
        self.splashAd = nil
    }
    
    func splashAdClosed(_ splashAd: GDTSplashAd!) {
        self.channel.invokeMethod("close", arguments: nil)
        print("开屏广告关闭回调")
    }
    
    func splashAdDidPresentFullScreenModal(_ splashAd: GDTSplashAd!) {
        print("开屏广告点击以后弹出全屏广告页")
    }
    
    func splashAdWillDismissFullScreenModal(_ splashAd: GDTSplashAd!) {
        print("点击以后全屏广告页将要关闭")
    }
    
    func splashAdDidDismissFullScreenModal(_ splashAd: GDTSplashAd!) {
        print("点击以后全屏广告页已经关闭")
    }
}
