//
//  D4HDownloadGroupRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 15/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HDownloadGroupRequest: D4HRequest {
    
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
            "reqID": reqID
        ]
        print(params)
        return params
    }
}


