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

class NetworkManager {
    
    //MARK:  Singleton pattern
    
    static let sharedInstance = NetworkManager()
    
    //DATA4HELP API
    
    func sendPostRequest(
        input: D4HRequest,
        endpoint: D4HEndpoint,
        completionHandler: @escaping(JSON?, Error?) -> Void
        ) {
        os_log("NetworkManager request: %@endpoint", log: OSLog.default, type: .debug)
        
        Alamofire.request(self.getD4HUrlWithKey(endpoint: endpoint), method: HTTPMethod.post, parameters: input.getParams(), encoding: JSONEncoding.default, headers: nil).responseJSON { (dataResponse) in
            
            // Manage response
            
            if let data = dataResponse.data {
                print("Response: SUCCESS")
                let json = JSON(data)
                completionHandler(json, nil)
            } else if let error = dataResponse.error {
                print("Response: ERROR")
                completionHandler(nil,error)
            }
        }
    }
    
    func sendGetRequest(
        input: D4HRequest,
        endpoint: D4HEndpoint,
        headers: HTTPHeaders,
        completionHandler: @escaping(JSON?, Error?) -> Void
        ) {
        os_log("NetworkManager request: %@endpoint", log: OSLog.default, type: .debug)
        
        Alamofire.request(self.getD4HUrlWithKey(endpoint: endpoint), method: HTTPMethod.get, parameters: input.getParams(), encoding: JSONEncoding.default, headers: headers).responseJSON { (dataResponse) in
            
            // Manage response
            
            if let data = dataResponse.data {
                print("Response: SUCCESS")
                let json = JSON(data)
                completionHandler(json, nil)
            } else if let error = dataResponse.error {
                print("Response: ERROR")
                completionHandler(nil,error)
            }
        }
    }
    
    // MARK: - Private implementation
    
    private struct GCP {
        static let D4HAPIbaseURL = "http://127.0.0.1:3000"
    }
    
    private func getD4HUrlWithKey(endpoint: D4HEndpoint) -> URL {
        let urlString = GCP.D4HAPIbaseURL + endpoint.rawValue
        return URL(string: urlString)!
    }
    
}
