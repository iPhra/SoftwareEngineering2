//
//  SUSingleRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON

class SUSingleRequest {
    
    // MARK: - Properties

    let reqid: String
    let email: String
    let piva: String
    let company_name: String
    var types: [dataType]
    let status: String
    let subscribing: Bool
    let duration: Int?
    let date: String
    let expired: Bool
    
    // MARK: - initialization
    
    init( reqid: String, email: String, piva: String, company_name: String, types: [dataType], status: String, subscribing: Bool, duration: Int?, date: String, expired: Bool) {
        self.reqid = reqid
        self.email = email
        self.piva = piva
        self.company_name = company_name
        self.types = types
        self.status = status
        self.subscribing = subscribing
        self.duration = duration
        self.date = date
        self.expired = expired
    }
    
    init(fromJson json: JSON) {
        print(json)
        self.reqid = json["reqid"].stringValue
        self.email = json["email"].stringValue
        self.piva = json["piva"].stringValue
        self.company_name = json["company_name"].stringValue
        let typesJson = json["types"].arrayValue
        self.types = []
        for typeJson in typesJson {
            let type = typeJson["datatype"].stringValue
            self.types.append(dataType(rawValue: type)!)
        }
        self.status = json["status"].stringValue
        self.subscribing = json["subscribing"].boolValue
        self.duration = json["duration"].intValue
        self.date = json["req_date"].stringValue
        self.expired = json["expired"].boolValue
    }
    
}
