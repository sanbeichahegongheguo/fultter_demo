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
    let channel:FlutterMethodChannel
    let messenger:FlutterBinaryMessenger
    private var bannerView:GDTUnifiedBannerView!
    
    init(withFrame: CGRect, viewId: Int64, args: Any?, controller: UIViewController,messenger:FlutterBinaryMessenger){
        self.messenger = messenger
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.withFrame = withFrame
        self.controller = controller
        self.channel = FlutterMethodChannel(name: "banner_"+String(viewId), binaryMessenger: messenger)
        super.init()
        self.channel.setMethodCallHandler(handle)
        initBnnerView()
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
        if bannerView == nil {
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
        print("请求广告条数据失败后调用")
        print(error)
    }
    
    func unifiedBannerViewDidLoad(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("请求广告条数据成功后调用")
    }
    
    func unifiedBannerViewWillExpose(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("banner2.0曝光回调")
        
    }
    
    func unifiedBannerViewClicked(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("banner2.0点击回调")
        
    }
    
    func unifiedBannerViewWillPresentFullScreenModal(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("banner2.0广告点击以后即将弹出全屏广告页")
        
    }
    
    func unifiedBannerViewDidPresentFullScreenModal(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("banner2.0广告点击以后弹出全屏广告页完毕")
        
    }
    
    func unifiedBannerViewWillDismissFullScreenModal(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("全屏广告页即将被关闭")
        
    }
    
    func unifiedBannerViewDidDismissFullScreenModal(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("全屏广告页已经被关闭")
    }
    
    func unifiedBannerViewWillLeaveApplication(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("当点击应用下载或者广告调用系统程序打开")
    }
    
    func unifiedBannerViewWillClose(_ unifiedBannerView: GDTUnifiedBannerView) {
        print("banner2.0被用户关闭时调用")
    }
}
