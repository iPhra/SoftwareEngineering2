//
//  D4HDownloadSingleRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 15/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HDownloadSingleRequest: D4HRequest {
    
    // MARK: - Properties
    
    let authToken: String
    let reqID: String
    
    // MARK: Initialisation
    
    init(authToken: String,  reqID: String) {
        self.authToken = authToken
        self.reqID = reqID
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "authToken": authToken,
            "reqID": reqID
        ]
        print(params)
        return params
    }
}

