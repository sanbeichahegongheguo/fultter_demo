import Flutter
import UIKit

public class SwiftYondorWhiteboardPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "yondor_whiteboard", binaryMessenger: registrar.messenger())
    let instance = SwiftYondorWhiteboardPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(YondorWhiteboardFactory(messenger:registrar.messenger()), withId: "whiteboard_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
