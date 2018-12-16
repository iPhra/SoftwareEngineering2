//
//  TPGroupRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class TPGroupRequest {
    
    // MARK: - Properties
    
    let reqid: String
    var types: [dataType]
    var parameters: [D4HHealthParameter]
    let status: String
    let subscribing: Bool
    let duration: Int
    
    // MARK: - initialization
    
    init( reqid: String, types: [dataType], parameters: [D4HHealthParameter], status: String, subscribing: Bool, duration: Int) {
        self.reqid = reqid
        self.types = types
        self.parameters = parameters
        self.status = status
        self.subscribing = subscribing
        self.duration = duration
    }
    
    init(fromJson json: JSON) {
        self.reqid = json["reqid"].stringValue
        let typesJson = json["types"].arrayValue
        self.types = []
        for typeJson in typesJson {
            let type = typeJson["dataType"].stringValue
            self.types.append(dataType(rawValue: type)!)
        }
        self.parameters = []
        let parametersJson = json["parameters"].arrayValue
        for parameterJson in parametersJson {
            self.parameters.append(D4HHealthParameter(fromJson: parameterJson))
        }
        self.status = json["status"].stringValue
        self.subscribing = json["subscribing"].boolValue
        self.duration = json["duration"].intValue
    }
    
}
