//
//  D4HSingleRegisterRequest.swift
//  Data4Help
//
//  Created by Luca Molteni on 03/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class D4HSingleRegisterRequest: D4HRequest {
    
    // MARK: - Properties
    
    let email: String
    let password: String
    let FC: String
    let fullname: String
    let birthday: String
    let sex: String
    
    // MARK: Initialisation
    
    init(email: String, password: String, FC: String, fullname: String, birthday: String, sex: String) {
        self.email = email
        self.password = password
        self.FC = FC
        self.fullname = fullname
        self.birthday = birthday
        self.sex = sex
        super.init(encodingType: D4HEncodingType.UTF16)
    }
    
    // MARK: - Networking
    
    override func getParams() -> Parameters {
        let params: Parameters = [
            "email": email,
            "password": password,
            "FC": FC,
            "fullname": fullname,
            "birthday": birthday,
            "sex": sex,
        ]
        print(params)
        return params
    }
}
