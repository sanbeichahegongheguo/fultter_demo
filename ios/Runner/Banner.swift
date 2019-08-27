//
//  Banner.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation
class Banner : NSObject, FlutterPlatformView, GDTUnifiedBannerViewDelegate{
    let viewId:Int64
    let args: NSDictionary
    let withFrame:CGRect
    let controller: UIViewController
    let registrar: FlutterPluginRegistrar
    let channel:FlutterMethodChannel
    private var bannerView:GDTUnifiedBannerView!
    
    init(withFrame: CGRect, viewId: Int64, args: Any?, controller: UIViewController,registrar: FlutterPluginRegistrar){
        self.registrar = registrar
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.withFrame = withFrame
        self.controller = controller
        self.channel = FlutterMethodChannel(name: "banner_"+String(viewId), binaryMessenger: registrar.messenger())
        super.init()
        self.channel.setMethodCallHandler(handle)
        self.initBnnerView()
        
    }
    
    public func view() -> UIView {
        return bannerView;
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadAD":
            initBnnerView()
            result(nil)
            break
        case "refreshBanner":
            initBnnerView()
            result(nil)
            break
        default:
            result(nil)
            break
        }
    }
    
    func initBnnerView(){
        if bannerView == nil{
            bannerView = GDTUnifiedBannerView.init(frame: withFrame,
                                                  appId: args.object(forKey: "appId") as! String,
                                                  placementId: args.object(forKey: "bannerId") as! String,
                                                  viewController: controller)
            bannerView.delegate = self
            bannerView.autoSwitchInterval = 0
        }
        bannerView.loadAdAndShow()
    }
    func unifiedBannerViewFailed(toLoad unifiedBannerView: GDTUnifiedBannerView, error: Error) {
        print(error)
    }
}
