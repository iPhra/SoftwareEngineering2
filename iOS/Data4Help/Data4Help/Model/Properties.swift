//
//  Properties.swift
//  Data4Help
//
//  Created by Luca Molteni on 14/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Properties {
    
    static var authToken: String = ""

    
    static func logout() {
        self.authToken = ""
    }
    
    static func auth() -> [String : String] {
        return ["x-authToken" : self.authToken]
    }
    
    static func logout(controller: UIViewController) {
                // Reset authToken
                self.authToken = ""
                controller.performSegue(withIdentifier: "BackToLogin", sender: controller)
    }
}


