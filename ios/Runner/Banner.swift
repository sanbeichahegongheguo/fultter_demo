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
    private var bannerView:GDTUnifiedBannerView!
    
    init(withFrame: CGRect, viewId: Int64, args: Any?, controller: UIViewController) {
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.withFrame = withFrame
        self.controller = controller
    }
    
    public func view() -> UIView {
        self.initBnnerView()
        return bannerView;
    }
    
    func initBnnerView(){
        if bannerView == nil{
            bannerView = GDTUnifiedBannerView.init(frame: withFrame,
                                                  appId: args.object(forKey: "appId") as! String,
                                                  placementId: args.object(forKey: "bannerId") as! String,
                                                  viewController: controller)
            bannerView.delegate = self
            bannerView.autoSwitchInterval = 0
            bannerView.loadAdAndShow()
        }
    }
    func unifiedBannerViewFailed(toLoad unifiedBannerView: GDTUnifiedBannerView, error: Error) {
        print(error)
    }
}
