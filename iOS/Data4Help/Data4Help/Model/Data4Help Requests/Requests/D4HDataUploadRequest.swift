//
//  D4HDataUploadRequest.swift
//  Data4Help
//
//  Created by Virginia Negri on 12/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HDataUploadRequest: D4HRequest {
    // MARK: - Properties
    
    let authToken: String
    let types: [dataTypes]
    let values: [Double]
    let timestamps: [String]
    
    // MARK: Initialisation
    
    init(authToken: String, types: [dataTypes],values: [Double], timestamps: [String]) {
        self.authToken = authToken
        self.types = types
        self.values = values
        self.timestamps = timestamps
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "authToken": authToken,
            "types": types,
            "values" : values,
            "timestamps" : timestamps
        ]
        print(params)
        return params
    }
    
}
