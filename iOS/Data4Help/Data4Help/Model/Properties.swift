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
    
    // MARK: Constants
    
    static let USER: String = "username"
    static let PASSWORD: String = "password"
    
    // MARK: Properties
    
    static var authToken: String = ""
    static var username: String = ""
    static var password: String = ""
    
    // MARK: Actions
    
    // Permanently stores user's credentials
    static func saveUserandPass(user: String, pass: String) {
        UserDefaults.standard.set(user, forKey: USER)
        UserDefaults.standard.set(pass, forKey: PASSWORD)
        print("credientials saved")
    }
    
    // Retrieve users credentials from storage
    static func getNameAndAddress() {
        self.username = UserDefaults.standard.value(forKey: USER) as? String ?? ""
        self.password = UserDefaults.standard.value(forKey: PASSWORD) as? String ?? ""
        print("credientials retrieved")
    }
    
    // Delete all user credentials
    static func logout() {
        
        // Reset authToken
        UserDefaults.standard.removeObject(forKey: USER)
        UserDefaults.standard.removeObject(forKey: PASSWORD)
        self.authToken = ""
        self.username = ""
        self.password = ""
        print("credientials deleted")
    }
    
    // Return auth header
    static func auth() -> [String : String] {
        return ["x-authToken" : self.authToken]
    }
    
    // Delete all user credentials and goes back to login
    static func logout(controller: UIViewController) {
                // Reset authToken
                UserDefaults.standard.removeObject(forKey: USER)
                UserDefaults.standard.removeObject(forKey: PASSWORD)
                self.authToken = ""
                self.username = ""
                self.password = ""
                print("credientials deleted")
                controller.performSegue(withIdentifier: "BackToLogin", sender: controller)
    }
}


