//
//  Banner.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation
import UIKit

class YondorWhiteboard : NSObject, FlutterPlatformView{
    let viewId:Int64
    let args: NSDictionary
    let uuid:String
    let roomToken:String
    let appIdentifier:String
    let withFrame:CGRect
    let channel:FlutterMethodChannel
    let messenger:FlutterBinaryMessenger
    var isDisableDeviceInputs:Bool
    private var sdk:WhiteSDK!
    let boardView:WhiteBoardView
    var room:WhiteRoom!
    init(withFrame: CGRect, viewId: Int64, args: Any?,messenger:FlutterBinaryMessenger){
         print("YondorWhiteboard init @@" )
        self.messenger = messenger
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.uuid = self.args["uuid"] as! String
        self.roomToken = self.args["roomToken"] as! String
        self.appIdentifier = self.args["appIdentifier"] as! String
        self.withFrame = withFrame
        self.channel = FlutterMethodChannel(name: "com.yondor.live/whiteboard_"+String(viewId), binaryMessenger: messenger)
        self.boardView = WhiteBoardView.init(frame: self.withFrame,configuration:WKWebViewConfiguration.init())
        self.boardView.isOpaque = false
        self.boardView.backgroundColor = UIColor.clear
        self.boardView.scrollView.backgroundColor = UIColor.clear
        self.isDisableDeviceInputs = false;
        super.init()
        self.initSdk()
        self.channel.setMethodCallHandler(handle)
       
    }
    
    func view() -> UIView {
        return boardView;
    }
    
    private func initSdk(){
        let conifg = WhiteSdkConfiguration.init(app:self.appIdentifier)
        self.sdk = WhiteSDK.init(whiteBoardView: self.boardView, config: conifg, commonCallbackDelegate: nil)
        let roomConfig =  WhiteRoomConfig.init(uuid: self.uuid, roomToken: self.roomToken)
        roomConfig.isWritable = false
        self.sdk.joinRoom(with: roomConfig, callbacks: nil) { (success:Bool, whiteRoom:WhiteRoom?, e:Error?) in
            print("joinRoom success @@" )
            print(success);
            if (success){
                self.room = whiteRoom!
                self.disableCameraTransform(disabled:true);
                self.setWritable(writable: false);
            }
        
        }
    
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateRoom":
            let dict = call.arguments as! NSDictionary
            let isBoardLock =  dict["isBoardLock"] as! Int
            self.disableCameraTransform(disabled: isBoardLock==1);
            break
        default:
            result(nil)
            break
        }
    }
    
    public func dispose(){
        self.room?.disconnect()
    }
    public func setWritable(writable:Bool){
         if (self.room != nil) {
            self.room.setWritable(writable, completionHandler: {(aBoolean:Bool, e:Error?) in
                print("#1 aBoolean",aBoolean )
                print("#2 Error ",e?.localizedDescription)
            })
         }
     }
    
    public func disableCameraTransform(disabled:Bool) {
        if (disabled != self.isDisableDeviceInputs) {
            if (disabled) {
                self.room.disableDeviceInputs(true);
            } else {
                self.room.disableDeviceInputs(self.isDisableDeviceInputs);
            }
        }
        self.room.disableCameraTransform(disabled);
        self.isDisableDeviceInputs = disabled;
    }

}


class YondorWhiteboardFactory: NSObject,FlutterPlatformViewFactory{
     let messenger: FlutterBinaryMessenger
     
     init(messenger: FlutterBinaryMessenger) {
         self.messenger = messenger
     }
     
     public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
         return YondorWhiteboard(withFrame:frame, viewId: viewId, args: args,messenger:messenger)
     }
     
     func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
         return FlutterStandardMessageCodec.sharedInstance()
     }
}
