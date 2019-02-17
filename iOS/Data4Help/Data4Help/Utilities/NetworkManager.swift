//
//  NetworkManager.swift
//  Data4Help
//
//  Created by Luca Molteni on 27/11/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import os.log

extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}


class NetworkManager {
    
    //MARK:  Singleton pattern
    
    static let sharedInstance = NetworkManager()
    
    //DATA4HELP API
    
    func sendPostRequest(
        input: D4HRequest,
        endpoint: D4HEndpoint,
        headers: HTTPHeaders?,
        completionHandler: @escaping(JSON?, String?) -> Void
        ) {
        os_log("NetworkManager request: %@endpoint", log: OSLog.default, type: .debug)
        
        Alamofire.SessionManager.default.requestWithoutCache(self.getD4HUrlWithKey(endpoint: endpoint), method: HTTPMethod.post, parameters: input.getParams(), encoding: JSONEncoding.default, headers: headers).responseJSON { (dataResponse) in
            if let data = dataResponse.data {
                let json = JSON(data)
                switch (dataResponse.response?.statusCode) {
                case 200:
                    print("Response: SUCCESS")
                    completionHandler(json, nil)
                default:
                    print("Response: ERROR")
                    guard json["error"].string != nil else {
                        return completionHandler(nil,"Server is temporarily unavailable")
                    }
                    completionHandler(nil,json["error"].string!)
                }
            } else if let error = dataResponse.error {
                print("Response: ERROR")
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    func sendGetRequest(
        input: D4HRequest,
        endpoint: D4HEndpoint,
        headers: HTTPHeaders,
        completionHandler: @escaping(JSON?, String?) -> Void
        ) {
        os_log("NetworkManager request: %@endpoint", log: OSLog.default, type: .debug)
        
        Alamofire.SessionManager.default.requestWithoutCache(self.getD4HUrlWithKey(endpoint: endpoint), method: HTTPMethod.get, parameters: input.getParams(), headers: headers).responseJSON { (dataResponse) in
            
            // Manage response
            
            if let data = dataResponse.data {
                print("Response: SUCCESS")
                let json = JSON(data)
                switch (dataResponse.response?.statusCode) {
                case 200,
                     304:
                    print("Response: SUCCESS")
                    completionHandler(json, nil)
                default:
                    print("Response: ERROR")
                    guard json["error"].string != nil else {
                        return completionHandler(nil,"Server is temporarily unavailable")
                    }
                    completionHandler(nil,json["error"].string!)
                }
            } else if let error = dataResponse.error {
                print("Response: ERROR")
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private implementation
    
    private struct GCP {
        static let D4HAPIbaseURL = "http://127.0.0.1:3000"
        static let D4HAPIbaseURLdeployed = "http://52.57.95.222"
    }
    
    private func getD4HUrlWithKey(endpoint: D4HEndpoint) -> URL {
        let urlString = GCP.D4HAPIbaseURLdeployed + endpoint.rawValue
        return URL(string: urlString)!
    }
    
}
