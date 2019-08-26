//
//  BannerViewFactory.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation
class BannerViewFactory : NSObject, FlutterPlatformViewFactory {
    let controller: UIViewController
    let registrar: FlutterPluginRegistrar
    
    init(controller: UIViewController,registrar: FlutterPluginRegistrar) {
        self.controller = controller
        self.registrar = registrar
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return Banner(withFrame:frame, viewId: viewId, args: args, controller: controller,registrar:registrar)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
