//
//  D4HChoiceRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HChoiceRequest: D4HRequest {
    
    // MARK: - Properties
    
    let authToken: String
    let reqID: String
    let choice: Bool
    
    // MARK: Initialisation
    
    init(authToken: String,  reqID: String, choice: Bool) {
        self.authToken = authToken
        self.reqID = reqID
        self.choice = choice
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "authToken": authToken,
            "reqID": reqID,
            "choice": choice
        ]
        print(params)
        return params
    }
}
