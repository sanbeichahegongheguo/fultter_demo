import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        //Banner需要使用到controller
        let controller = window?.rootViewController
        if !hasPlugin("BannerPlugin") && controller != nil {
            print("registar BannerPlugin")
            //注册插件
            BannerPlugin.registerWithRegistrar(registar: registrar(forPlugin: "BannerPlugin"), controller: controller!)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
