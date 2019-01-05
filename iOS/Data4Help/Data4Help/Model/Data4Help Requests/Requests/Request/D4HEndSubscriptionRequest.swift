//
//  D4HEndSubscriptionRequest.swift
//  Data4Help
//
//  Created by Virginia Negri on 05/01/2019.
//  Copyright © 2019 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import Alamofire

class D4HEndSubscriptionRequest: D4HRequest {
    
    // MARK: - Properties
    
    let reqID: String
    
    // MARK: Initialisation
    
    init(reqID: String) {
        self.reqID = reqID
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "reqID": reqID,
        ]
        print(params)
        return params
    }
}
