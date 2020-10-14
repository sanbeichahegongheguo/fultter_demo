//
//  Banner.swift
//  Runner
//
//  Created by yondor on 2019/8/5.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

import Foundation
import UIKit

class YondorWhiteboard : NSObject, FlutterPlatformView,WhiteCommonCallbackDelegate, WhitePlayerEventDelegate{
    let viewId:Int64
    let args: NSDictionary
    let uuid:String
    let roomToken:String
    let appIdentifier:String
    let isReplay:Int
    let withFrame:CGRect
    let channel:FlutterMethodChannel
    let messenger:FlutterBinaryMessenger
    var isDisableDeviceInputs:Bool
    private var sdk:WhiteSDK!
    let boardView:WhiteBoardView
    var room:WhiteRoom!
    var player:WhitePlayer!
    init(withFrame: CGRect, viewId: Int64, args: Any?,messenger:FlutterBinaryMessenger){
        print("YondorWhiteboard init @@" )
        self.messenger = messenger
        self.viewId = viewId
        //这是在flutter里面创建view的时候传入的参数
        self.args = args as! NSDictionary
        self.uuid = self.args["uuid"] as! String
        self.roomToken = self.args["roomToken"] as! String
        self.appIdentifier = self.args["appIdentifier"] as! String
        self.isReplay = self.args["isReplay"] as! Int
        self.withFrame = withFrame
        self.channel = FlutterMethodChannel(name: "com.yondor.live/whiteboard_"+String(viewId), binaryMessenger: messenger)
        self.boardView = WhiteBoardView.init(frame: self.withFrame,configuration:WKWebViewConfiguration.init())
        self.boardView.isOpaque = false
        self.boardView.backgroundColor = UIColor.clear
        self.boardView.scrollView.backgroundColor = UIColor.clear
        self.isDisableDeviceInputs = false;
        super.init()
        self.channel.setMethodCallHandler(handle)
        let conifg = WhiteSdkConfiguration.init(app:self.appIdentifier)
        self.sdk = WhiteSDK.init(whiteBoardView: self.boardView, config: conifg, commonCallbackDelegate: self)
        if (self.isReplay==1){
            var result = [String : Any]()
            result["created"] = true
            self.channel.invokeMethod("onCreated",arguments: result);
        }else{
            self.joinRoom()
        }
    }
    
    func view() -> UIView {
        return boardView;
    }
    
    private func joinRoom(){
        
        let roomConfig =  WhiteRoomConfig.init(uuid: self.uuid, roomToken: self.roomToken)
        roomConfig.timeout = NSNumber(value: 60*60*2)
        roomConfig.isWritable = false
        self.sdk.joinRoom(with: roomConfig, callbacks: nil) { (success:Bool, whiteRoom:WhiteRoom?, e:Error?) in
            print("YondorWhiteboard joinRoom success @@" )
            print(success);
            var result = [String : Any]()
            result["created"] = success
            self.channel.invokeMethod("onCreated", arguments: result)
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
        case "start":
            self.startReplay(call: call,result: result);
            result(nil)
            break;
        case "pause":
            self.pause();
            result(nil);
            break;
        case "play":
            self.play();
            result(nil);
            break;
        case "replay":
            replay();
            result(nil);
            break;
        case "seekToScheduleTime":
            let dict = call.arguments as! NSDictionary
            let timeStr = dict["data"] as! String
            let formattor = NumberFormatter()
            let timeNum =  formattor.number(from: timeStr)!
            let time:TimeInterval = TimeInterval.init(exactly: timeNum)!
            self.seekToScheduleTime(time: time);
            result(nil);
            break;
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
                print("YondorWhiteboard #1 aBoolean",aBoolean )
                print("YondorWhiteboard #2 Error ",e?.localizedDescription)
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
    
    public func throwError(_ error:Error){
        print("YondorWhiteboard #3 throwError ",error.localizedDescription)
    }
    
    
    public func sdkSetupFail(_ error:Error) {
        print("YondorWhiteboard #4 sdkSetupFail ",error.localizedDescription)
    }
    
    
    func startReplay(call: FlutterMethodCall, result: @escaping FlutterResult){
        let dict = call.arguments as! NSDictionary
        let beginTimestamp:String = dict["beginTimestamp"] as! String
        let duration:String = dict["duration"] as! String
//        let mediaUrl = dict["mediaURL"] as! String
        let whitePlayerConfig =  WhitePlayerConfig.init(room: self.uuid, roomToken: self.roomToken)
        let number = NumberFormatter.init()
        whitePlayerConfig.beginTimestamp = number.number(from: beginTimestamp)
        whitePlayerConfig.duration = number.number(from: duration)
//        whitePlayerConfig.mediaURL = mediaUrl
        print("YondorWhiteboard whitePlayerConfig.beginTimestamp ",whitePlayerConfig.beginTimestamp)
        print("YondorWhiteboard whitePlayerConfig.duration ",whitePlayerConfig.duration)
        self.sdk.createReplayer(with: whitePlayerConfig, callbacks: self ,completionHandler: { (success:Bool,whitePlayer:WhitePlayer?, err:Error?) in
            if(success){
                print("YondorWhiteboard #startReplay success")
                self.player = whitePlayer!
                whitePlayer?.play()
            }else {
                print("YondorWhiteboard #startReplay ",err?.localizedDescription)
            }
        })
        
    }
    //播放状态切换回调
    func phaseChanged(_ phase:WhitePlayerPhase) {
        print("YondorWhiteboard phaseChanged ",phase)
        self.replayOnPhaseChanged(phase: phase);
    }
    //首帧加载回调
    func loadFirstFrame( ) {
        print("YondorWhiteboard loadFirstFrame")
    }
    // 分片切换回调，需要了解分片机制。目前无实际用途
    func sliceChanged(_ slice:String){
        print("YondorWhiteboard slice %s",slice)
    }
    //播放中，状态出现变化的回调
    func playerStateChanged(_ modifyState:WhitePlayerState){
        print("YondorWhiteboard onPlayerStateChanged ",modifyState);
    }
    /** 出错暂停 */
    func stoppedWithError(_ error:Error){
        print("YondorWhiteboard onStoppedWithError %s",error.localizedDescription);
    }
    /** 进度时间变化 */
    func scheduleTimeChanged(_ time:TimeInterval){
        print("YondorWhiteboard onScheduleTimeChanged %d",time);
        self.replayOnScheduleTimeChanged(time: time);
    }
    /** 添加帧出错 */
    func error(whenAppendFrame error:Error){
        print("YondorWhiteboard onCatchErrorWhenAppendFrame %s",error.localizedDescription);
    }
    /** 渲染时，出错 */
    func error(whenRender error:Error){
        print("YondorWhiteboard onCatchErrorWhenRender %s",error.localizedDescription);
    }
    //开始播放
    func play(){
        if (checkPlayerIsNull()){
            return;
        }
        self.player.play();
    }
    func pause(){
        if (checkPlayerIsNull()){
            return;
        }
        self.player.pause();
    }
    
    //重新播放
    func replay(){
        if (checkPlayerIsNull()){
            return;
        }
        self.player.seek(toScheduleTime: 0);
        self.player.play();
    }
    
    //状态变化
    func replayOnPhaseChanged(phase:WhitePlayerPhase){
        if (checkPlayerIsNull()){
            return;
        }
        var result = [String : Any]()
        var data:String = ""
        switch phase {
        case .waitingFirstFrame:
            data = "waitingFirstFrame"
        case .playing:
            data = "playing"
        case .pause:
            data = "pause"
        case .stopped:
            data = "stopped"
        case .ended:
            data = "ended"
        case .buffering:
            data = "buffering"
        @unknown default:
            data = ""
        }
        result["data"] = data
        self.postMsg(method: "onPhaseChanged",data: result);
    }
    
    //时间变化
    func replayOnScheduleTimeChanged(time:TimeInterval){
        if (checkPlayerIsNull()){
            return;
        }
        var result = [String : Any]()
        result["data"] = time
        postMsg(method: "onScheduleTimeChanged",data: result);
    }
    //时间跳转
    func seekToScheduleTime(time:TimeInterval){
        
        if (checkPlayerIsNull()){
            return;
        }
        print("YondorWhiteboard seekToScheduleTime",time);
        self.player.seek(toScheduleTime: time);
    }
    
    
    
    func postMsg(method:String,data:[String : Any]){
        self.channel.invokeMethod(method, arguments: data)
    }
    
    func checkPlayerIsNull() -> Bool{
        if (self.player==nil){
            var result = [String : Any]()
            result["data"] = "player is null"
            self.postMsg(method: "error",data: result);
            return true
        }
        return false
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
