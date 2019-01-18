//
//  LoginViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 26/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        
        //Delete any shortcut that has not been properly deleted
        AppDelegate.deleteAllQuickShortcuts()
        
    }
    
    // MARK: Actions
    
    @IBAction func loginUser(_ sender: UIButton) {
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        // Save persistently user credentials
        //Properties.saveUserandPass(user: usernameTextField.text!, pass: passwordTextField.text!)
        
        login(email: usernameTextField.text!, password: passwordTextField.text!)
    }
    
    func configureDynamicShortcutItem() {
        let type = "com.lorenzomolteninegri.Data4Help.automatedSOS"
        let shortcutItem = UIApplicationShortcutItem.init(type: type, localizedTitle: "Enable AutomatedSOS", localizedSubtitle: nil, icon: UIApplicationShortcutIcon.init(type: UIApplicationShortcutIcon.IconType.love), userInfo:nil)
        
        UIApplication.shared.shortcutItems = [shortcutItem]
    }
    
    
    // MARK: Private implementation
    
    private func login(email: String, password: String) {
        
        print("Sending login request")
        
        //send request through Network Manager with login details
        print(D4HEndpoint.login)
        NetworkManager.sharedInstance.sendPostRequest(input: D4HLoginRequest(email: email, password: password), endpoint: D4HEndpoint.login, headers: nil) { (response, error) in
            if response != nil {
                let myres = D4HLoginResponse(fromJson: response!)
                print(myres.message)
                
                // Set authToken for the logged user
                Properties.authToken = myres.authToken
                print(Properties.authToken)
                // Perform segue either to Single user or Third Party interface
                if myres.userType == "PrivateUser" {
                    AppDelegate.shared.firstImport()
                    self.configureDynamicShortcutItem()
                    self.performSegue(withIdentifier: "GoToSingleUser", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GoToThirdParty", sender: self)
                }
                
            }
            else if let error = error {
                print(error)
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

