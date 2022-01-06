//
//  ZHWebSocketManager.swift
//  ZHKitDemo
//
//  Created by NetInfo on 2021/12/22.
//

import UIKit
import Alamofire
import SocketRocket

fileprivate enum NetStatus: String {
    case unknown        //未知网络
    case notReachable   //网络无连接
    case cellular       //蜂窝，2，3，4G网络
    case wifi           //wifi网络
}

class ZHWebSocketManager: NSObject, SRWebSocketDelegate {
    static let shared = ZHWebSocketManager()
    
    var heartBeat: String = "ping"
    
    /// 连接
    func connect(url urlStr: String, receiveMsg: ((_ msg: String)->Void)?){
        if webSocket != nil, urlStr.count == 0 {
            return
        }
        if let url = URL(string: urlStr) {
            serverURL = urlStr
            receiveMsgHandle = receiveMsg
            
            webSocket = SRWebSocket(url: url)
            webSocket?.delegate = self
            webSocket?.open()
        }
    }
    
    /// 断开连接
    func disconnet(){
        webSocket?.close()
        webSocket = nil
        
        destroyHeartBeat()
    }
    
    /// 发送消息
    func send(msg: String){
        guard let socket = webSocket else {
            self.connect(url: self.serverURL, receiveMsg: self.receiveMsgHandle)
            return
        }
        
        self.checkNetworkStatus { (status) in
            if status == .notReachable {
                self.netTesting()
            }else{
                switch socket.readyState {
                case .OPEN:
//                    socket.send(msg)
                    try? socket.send(string: msg)
                case .CONNECTING:
                    print("连接中，重连后自动同步数据")
                case .CLOSING:
                    print("断开中")
                case .CLOSED:
                    print("已断开")
                default:
                    print("readyState：\(socket.readyState)")
                }
            }
        }
    }
    
    private var serverURL: String = ""
    private var webSocket: SRWebSocket?
    private var receiveMsgHandle: ((_ msg: String)->Void)?
    
    private var heartBeatTimer: Timer?
    private var netTestingTimer: Timer?
    
    private var reconnectCount: TimeInterval = 0
}

// MARK: - Private
extension ZHWebSocketManager {
    //重新连接
    private func reconnet(){
        print("reConnectCount: \(self.reconnectCount)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (reconnectCount * 10) ) {
            
            if self.reconnectCount * 10 < 60 * 30 {
                self.reconnectCount += 1
            }
            self.connect(url: self.serverURL, receiveMsg: self.receiveMsgHandle)
            print("重新连接中...")
        }
    }
    
    //创建心跳包
    private func createHeartBeat(){
        if heartBeatTimer != nil {
            return
        }
        
        dispatch_main_async_safe {
            let timer = Timer(timeInterval: 10, repeats: true, block: { (timer) in
                print(Thread.current)
                self.send(msg: self.heartBeat)
            })
            self.heartBeatTimer = timer
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    //销毁心跳包
    private func destroyHeartBeat(){
        dispatch_main_async_safe {
            self.heartBeatTimer?.invalidate()
            self.heartBeatTimer = nil
        }
    }
    
    //定时网络监测
    private func netTesting(){
        if self.netTestingTimer == nil {
            let timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
                //获取网络状态
                self.checkNetworkStatus { (status) in
                    if status != .notReachable {//直到有网，停止监测并重连服务器
                        print("Reachable")
                        self.closeNetTesting()
                        self.reconnet()
                    }else{
                        print("notReachable")
                    }
                }
            })
            self.netTestingTimer = timer
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func checkNetworkStatus(netWorkStatus: @escaping (_ netStatus: NetStatus)->Void) {
        let reachability = NetworkReachabilityManager.default
        reachability?.startListening(onUpdatePerforming: { (status) in
            switch status {
            case .notReachable:
                netWorkStatus(.notReachable)
            case .unknown:
                netWorkStatus(.unknown)
            case .reachable(.cellular):
                netWorkStatus(.cellular)
            case .reachable(.ethernetOrWiFi):
                netWorkStatus(.wifi)
            default:
                netWorkStatus(.notReachable)
            }
        })
    }
    
    //关闭网络监测
    private func closeNetTesting(){
        self.netTestingTimer?.invalidate()
        self.netTestingTimer = nil
    }
}

// MARK: - SRWebSocketDelegate
extension ZHWebSocketManager {
    //已连接
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        createHeartBeat()
        closeNetTesting()
        reconnectCount = 0//重连成功，重置重连次数
        
    }
//    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
//        createHeartBeat()
//        closeNetTesting()
//        reConnectCount = 0//重连成功，重置重连次数
//        if curriculumId != -1 {//自动上线
//            Online(curriculumId: curriculumId)
//        }
//    }
    
    //链接失败（断网）
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        disconnet()
        netTesting()
    }
    
    //断开连接
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        destroyHeartBeat()
    }
    
    //收到消息
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        print(string)
        receiveMsgHandle?(string)
    }
    
    //接受服务端返回Pong消息（心跳包是ping消息，服务端会返回给我们一个pong消息）
    func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {
        if let pong = pongData, let json = String(data: pong, encoding: .utf8){
            print("Pong数据接收:\(json)")
        }
    }
}

// MARK: - GCD
func dispatch_main_async_safe(handle: @escaping ()->Void){
    if Thread.isMainThread {
        handle()
    }else{
        DispatchQueue.main.async {
            handle()
        }
    }
}
