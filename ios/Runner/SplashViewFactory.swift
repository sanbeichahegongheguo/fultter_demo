//
//  BannerViewFactory.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation
class SplashViewFactory : NSObject, FlutterPlatformViewFactory {
    let controller: UIViewController
    let messenger: FlutterBinaryMessenger
    
    init(controller: UIViewController,messenger: FlutterBinaryMessenger) {
        self.controller = controller
        self.messenger = messenger
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return SplashView(withFrame:frame, viewId: viewId, args: args, controller: controller,messenger:messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
