//
//  D4HSingleListRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 15/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HSingleListRequest: D4HRequest {
    
    // MARK: - Properties
    
    
    // MARK: Initialisation
    
    init(authToken: String) {
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [:]
        print(params)
        return params
    }
}
