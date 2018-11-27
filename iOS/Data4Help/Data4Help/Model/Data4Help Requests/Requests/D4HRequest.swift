//
//  D4HRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 27/11/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import Alamofire

class D4HRequest {
    
    // MARK: Properties
    
    let encodingType: D4HEncodingType
    
    // MARK: initialization
    
    init(encodingType: D4HEncodingType) {
        self.encodingType = encodingType
    }
    
    // MARK: Networking
    
    func getParams() -> Parameters {
        let params: Parameters = [
            "encodingType": encodingType.rawValue
        ]
        print(params)
        return params
    }
}
