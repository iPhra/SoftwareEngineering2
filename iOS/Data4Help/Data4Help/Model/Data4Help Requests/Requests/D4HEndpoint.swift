//
//  D4HEndpoint.swift
//  Data4Help
//
//  Created by Luca Molteni on 27/11/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation

enum D4HEndpoint: String {
    
    // Authentication
    
    case login = "/auth/login"
    case registerSingle = "/auth/reg/single"
    case registerThirdParty = "/auth/reg/tp"
    case activation = "/auth/activ"
    case logout = "/auth/logout"
    
    // Settings
    
    case setInfoSingle = "/settings/single/info"
    case setDataSingle = "/settings/single/data"
    case setInfoThirdParty = "/settings/tp/info"
    
    // Request
    case requestListSingle = "/req/single/list"
    case requestListThirdParty = "/req/tp/list"
    case singleRequest = "/req/tp/sendSingle"
    case groupRequest = "/req/tp/sendGroup"
    case requestAnswer = "/req/single/choice"
    
    // Data
    
    case uploadData = "/data/upload"
    case statistics = "/data/stats"

}
