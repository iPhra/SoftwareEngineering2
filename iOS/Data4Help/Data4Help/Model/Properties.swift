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
    
    static func logout(controller: UIViewController) {
        NetworkManager.sharedInstance.sendGetRequest(input: D4HLogoutRequest(authToken: self.authToken), endpoint: D4HEndpoint.logout) { (response, error) in
            if response != nil {
                let myres = D4HLogoutResponse(fromJson: response!)
                // Reset authToken
                        self.authToken = ""
                print(myres.message)
                controller.performSegue(withIdentifier: "BackToLogin", sender: controller)
            }
            else if let error = error {
                print(error)
            }
        }
    }
}


