import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        //Banner需要使用到controller
        let controller = window?.rootViewController
        Yondor.register(self.registrar(forPlugin: "yondorChannel"))
        if !hasPlugin("BannerPlugin") && controller != nil {
            print("registar BannerPlugin")
            //注册插件
            BannerPlugin.registerWithRegistrar(registar: registrar(forPlugin: "BannerPlugin"), controller: controller!)
        }
        FLTCameraPlugin.register(with: self.registrar(forPlugin: "FLTCameraPlugin"))
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
