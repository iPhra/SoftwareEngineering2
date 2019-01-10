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
        
        // DEBUGGING FUNCTIONS
        // DELETE BEFORE DEPLOYMENT
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        view.addGestureRecognizer(swipe)
        
        // END DEBUGGING CALLS
        
        // Attempt to automatically login
        Properties.getNameAndAddress()
        if (Properties.password != "" && Properties.username != "") {
            print("Sending automatic login request")
            login(email: Properties.username, password: Properties.password)
        }
    }
    
    // MARK: Actions
    
    @IBAction func loginUser(_ sender: UIButton) {
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        // Save persistently user credentials
        Properties.saveUserandPass(user: usernameTextField.text!, pass: passwordTextField.text!)
        
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
                    self.performSegue(withIdentifier: "GoToSingleUser", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GoToThirdParty", sender: self)
                }
                
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
    
    // MARK: debugging functions
    // TO be deleted before deployment
    
    @objc func doubleTapped() {
        // do something here
        print("Secret login to third party")
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        login(email: "gruosso_industries@gmail.com", password: "data4help")
    }

    @objc func swiped() {
        // do something here
        print("Secret login to single user")
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        login(email: "moltek96@gmail.com", password: "datahelp")
    }
    
}

