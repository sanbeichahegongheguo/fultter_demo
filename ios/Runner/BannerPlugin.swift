//
//  BannerPlugin.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation

class BannerPlugin {
    static func registerWithRegistrar(registar: FlutterPluginRegistrar, controller: UIViewController){
        registar.register(BannerViewFactory(controller: controller,messenger:registar.messenger()), withId: "banner");
        registar.register(SplashViewFactory(controller: controller,messenger:registar.messenger()), withId: "splash");
    }
}
