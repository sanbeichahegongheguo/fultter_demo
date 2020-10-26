import Foundation

class SimplePingChannel {
    private let channelName = "com.yondor.simplePing"
    private var runningExecutors: Array<MySimplePingExecutor> = []
    
    func register(controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler(self.onMethodCall)
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "ping":
            let args = call.arguments as! Dictionary<String, Any>
            let executor = MySimplePingExecutor(hostName: args["hostName"] as! String, packetSize: args["packetSize"] as! Int, timeout: args["timeout"] as! Int)
            runningExecutors.append(executor)
            executor.send(onSuccess: { (value) in
                self.dropExecutor(executor)
                result(value)
            }) { (error) in
                self.dropExecutor(executor)
                result(FlutterError(
                    code: "MySimplePing#ping",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func dropExecutor(_ executor: MySimplePingExecutor) {
        if let index = runningExecutors.firstIndex(of: executor) {
            runningExecutors.remove(at: index)
        }
    }
}

class MySimplePingExecutor: NSObject, MySimplePingDelegate  {
    init(hostName: String, packetSize: Int, timeout: Int) {
        self.mySimplePing = MySimplePing(hostName: hostName)
        self.packetSize = packetSize
        self.timeout = timeout
    }
    
    private let packetSize: Int
    private let timeout: Int
    private var mySimplePing: MySimplePing
    private var onSuccess: ((Double) -> Void)? = nil
    private var onFailed: ((Error) -> Void)? = nil
    private var didSend: Bool = false
    private var sendTime: Date? = nil
    
    func send(onSuccess: @escaping (Double) -> Void, onFailed: @escaping (Error) -> Void) {
        if (!didSend) {
            didSend = true
            self.onSuccess = onSuccess
            self.onFailed = onFailed
            mySimplePing.delegate = self
            mySimplePing.start()
        }
    }
    
    func mySimplePing(_ pinger: MySimplePing, didStartWithAddress address: Data) {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let data = String((0..<packetSize).map{ _ in letters.randomElement()! }).data(using: .ascii)
        mySimplePing.send(with: data, timeout: UInt16(timeout))
    }
    
    func mySimplePing(_ pinger: MySimplePing, didFailWithError error: Error) {
        mySimplePing.stop()
        onFailed?(error)
    }
    
    func mySimplePing(_ pinger: MySimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        mySimplePing.stop()
        onFailed?(error)
    }
    
    func mySimplePing(_ pinger: MySimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        mySimplePing.stop()
        let result = -sendTime!.timeIntervalSinceNow * 1000.0
        onSuccess?(result)
    }
    
    func mySimplePing(_ pinger: MySimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        if (sendTime == nil) {
            sendTime = Date()
        }
    }
}

