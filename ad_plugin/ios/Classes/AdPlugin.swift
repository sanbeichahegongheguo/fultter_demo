import Flutter
import UIKit
import CommonCrypto

public class AdPlugin: NSObject, FlutterPlugin {
        public static func register(with registrar: FlutterPluginRegistrar) {
            registrar.register(BannerViewFactory(controller: controller), withId: "banner");
        }
}


class BannerViewFactory : NSObject, FlutterPlatformViewFactory {
    let controller: UIViewController

    init(controller: UIViewController) {
        self.controller = controller
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return Banner(withFrame:frame, viewId: viewId, args: args, controller: controller)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class Banner : NSObject, FlutterPlatformView, GDTUnifiedBannerViewDelegate{
    let viewId:Int64
    let args: NSDictionary
    let withFrame:CGRect
    let  controller: UIViewController

    init(withFrame: CGRect, viewId: Int64, args: Any?, controller: UIViewController) {
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.withFrame = withFrame
        self.controller = controller
    }

   public func view() -> UIView {
        let banner = GDTUnifiedBannerView.init(frame: withFrame,
            appId: args.object(forKey: "appid") as! String,
            placementId: args.object(forKey: "posId") as! String,
            viewController: controller)
        banner.delegate = self
        banner.loadAdAndShow()
        return banner;
    }

    func unifiedBannerViewFailed(toLoad unifiedBannerView: GDTUnifiedBannerView, error: Error) {
        print(error)
    }
}
