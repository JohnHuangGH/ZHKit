//
//  ZHNetManager.swift
//  ZHKitDemo
//
//  Created by NetInfo on 2022/1/4.
//

import UIKit

enum ZHNetMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

enum ZHNetParamsType {
    case `default`
    case json
}

fileprivate let kBoundary: String = String(format: "zhkit.boundary.%08x%08x", arc4random(), arc4random())

class ZHNetManager: NSObject {

    static let shared: ZHNetManager = ZHNetManager()
    
    var baseURL: String = ""
    var headers: [String: Any] = [:]
    
    /// 基础请求
    func request(url urlStr: String, params: [String: Any], method: ZHNetMethod, paramsType: ZHNetParamsType = .default, completed: ((_ res: Any?)->Void)?){
        // URL
        if urlStr.isEmpty { return }
        var fullURL = urlStr.contains("://") ? urlStr : baseURL + urlStr
        if method == .get || method == .delete {
            fullURL += "?\(getRequestParams(params))"
        }
        guard let url = URL(string: fullURL) else { return }
        // Request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue("\($1)", forHTTPHeaderField: $0) }
        if method == .post || method == .put {
            if paramsType == .default {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = getRequestParams(params).toData()
            }else{
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
        }
        // dataTask
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let _ = error { completed?(nil); return }
                
                guard let resData = data else { completed?(nil); return }
                let json = try? JSONSerialization.jsonObject(with: resData, options: .mutableContainers)
                completed?(json)
            }
        }.resume()
    }
    
    /// 多文件上传
    func uplaod(url urlStr: String, fileDict: [String: Data], name: String = "files", params: [String: Any]? = nil, completed: ((_ success: Bool)->Void)?){
        // URL
        if urlStr.isEmpty { return }
        let fullURL = urlStr.contains("://") ? urlStr : baseURL + urlStr
        guard let url = URL(string: fullURL) else { return  }
        // Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach{ request.addValue("\($1)", forHTTPHeaderField: $0) }
        request.addValue("multipart/form-data; boundary=\(kBoundary)", forHTTPHeaderField: "Content-Type")
        // body
        let body = getMultBody(fileDict: fileDict, boundary: kBoundary, name: name, params: params)
        // uploadTask
        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            DispatchQueue.main.async {
                if let _ = error { completed?(false); return }
                
                guard let resData = data, let json = try? JSONSerialization.jsonObject(with: resData, options: .mutableContainers), let resDict = json as? [String: Any], let resCode = resDict["code"] as? Int else { completed?(false); return }
                completed?(resCode == 200)
            }
        }.resume()
    }
}

extension ZHNetManager {
    /// 拼接请求参数
    private func getRequestParams(_ params: [String: Any]) -> String {
        var str = ""
        params.forEach { (key: String, value: Any) in
            str += "\(key)=\(value)&"
        }
        return str.zh_subString(to: str.count-1)
    }
    
    /// 拼接多文件上传请求体
    private func getMultBody(fileDict: [String: Data], boundary: String, name: String, params: [String: Any]?) -> Data {
        // 创建body
        var body = Data()
        
        if let p = params {
            p.forEach { (key: String, value: Any) in
                // --分隔线
                body.append("--\(boundary)\r\n".toData())
                // 传入参数
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".toData())
                body.append("\(value)\r\n".toData())
            }
        }
        
        fileDict.forEach { (fileName: String, file: Data) in
            // --分隔线
            body.append("--\(boundary)\r\n".toData())
            // 传入参数
            body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".toData())
            // 文件域
            body.append("Content-Type: multipart/form-data; boundary=\(boundary)\r\n\r\n".toData())
            body.append(file)
            body.append("\r\n".toData())
        }
        
        // --分隔线-- 整个表单的结束符
        body.append("--\(boundary)--\r\n".toData())
        return body
    }
    
}

extension String {
    fileprivate func toData() -> Data {
        return self.data(using: .utf8)!
    }
}
