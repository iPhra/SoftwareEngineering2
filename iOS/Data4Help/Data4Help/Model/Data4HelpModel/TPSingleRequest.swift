//
//  TPSingleRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class TPSingleRequest {
    
    // MARK: - Properties
    
    let reqid: String
    let email: String
    let fc: String
    let full_name: String
    var types: [dataType]
    let status: String
    let subscribing: Bool
    let duration: Int
    let date: String
    
    // MARK: - initialization
    
    init( reqid: String, email: String, fc: String, full_name: String, types: [dataType], status: String, subscribing: Bool, duration: Int, date: String) {
        self.reqid = reqid
        self.email = email
        self.fc = fc
        self.full_name = full_name
        self.types = types
        self.status = status
        self.subscribing = subscribing
        self.duration = duration
        self.date = date
    }
    
    init(fromJson json: JSON) {
        self.reqid = json["reqid"].stringValue
        self.email = json["email"].stringValue
        self.fc = json["fc"].stringValue
        self.full_name = json["full_name"].stringValue
        let typesJson = json["types"].arrayValue
        self.types = []
        for typeJson in typesJson {
            let type = typeJson["datatype"].stringValue
            self.types.append(dataType(rawValue: type)!)
        }
        self.status = json["status"].stringValue
        self.subscribing = json["subscribing"].boolValue
        self.duration = json["subscribing"].intValue
        self.date = json["req_date"].stringValue
    }
    
}

