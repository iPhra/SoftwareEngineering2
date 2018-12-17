//
//  D4HStatisticsRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 16/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HStatisticsRequest: D4HRequest {
    
    // MARK: - Properties
    
    let types: [dataType]
    
    // MARK: Initialisation
    
    init(types: [dataType]) {
        self.types = types
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "types": types
        ]
        print(params)
        return params
    }
}
