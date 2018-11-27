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
    
    func sendRequest(
        input: D4HRequest,
        endpoint: D4HEndpoint,
        completionHandler: @escaping(D4HResponse?, Error?) -> void
        ) {
        os_log("NetworkManager request: %@endpoint" + , log: OSLog.default, type: .debug)
        
        Alamofire.request(self.getNLUrlWithKey(endpoint: endpoint), method: HTTPMethod.post, parameters: input.getParams(), encoding: JSONEncoding.default, headers: nil).responseJSON { (dataResponse) in
            
            // Manage response
            
            if let data = dataResponse.data {
                print("analyzeEntitySentiment: SUCCESS")
                let json = JSON(data)
                completionHandler(GNLEntityResponse(fromJson: json), nil)
            } else if let error = dataResponse.error {
                print("analyzeEntitySentiment: ERROR")
                completionHandler(nil,error)
            }
        }
    }
    
}
