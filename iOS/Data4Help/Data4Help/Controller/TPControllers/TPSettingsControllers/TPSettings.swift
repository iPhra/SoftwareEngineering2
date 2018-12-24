//
//  TPSettings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPSettings: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bottomActionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Properties
    
    var TPViewSettings: TPViewSettings? = nil
    var TPEditSettings: TPEditSettings? = nil
    var edit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load child view controllers
        
        let storyboard = UIStoryboard(name: "ThirdParty", bundle: Bundle.main)
        
        // Instantiate View Controller
        let controller = storyboard.instantiateViewController(withIdentifier: "TPViewSettings") as! Data4Help.TPViewSettings
        
        TPViewSettings = controller
        
        let otherController = storyboard.instantiateViewController(withIdentifier: "TPEditSettings") as! Data4Help.TPEditSettings
        
        TPEditSettings = otherController
        
        //set current view controller
        
        addChild(controller)
        
        containerView.addSubview(controller.view)
        
        controller.didMove(toParent: self)
        
        loadinfo()
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        
        // Allow to reposition views when keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: Actions
    
    @IBAction func startEditing(_ sender: Any) {
        if(edit==0){
            
            addChild(TPEditSettings!)
            containerView.addSubview((TPEditSettings?.view)!)
            
            // Edit view setup
            self.TPEditSettings?.fillView(email: (TPViewSettings?.emailLabel.text)!, piva: (TPViewSettings?.pivaLabel.text)!)
            
            edit = 1
            editButton.setTitle("Close",for: .normal)
            bottomActionButton.setTitle("Save", for: .normal)
        }
        else{
            addChild(TPViewSettings!)
            containerView.addSubview((TPViewSettings?.view)!)
            edit = 0
            editButton.setTitle("Edit",for: .normal)
            bottomActionButton.setTitle("Logout", for: .normal)
        }
    }
    
    @IBAction func pressBottomAction(_ sender: UIButton) {
        // Logout and go back to Login View
        if (bottomActionButton.titleLabel?.text == "Logout") {
            // See implementation in Properties
            Properties.logout(controller: self)
            AppDelegate.deleteAllQuickShortcuts()
        }
        // Save edited settings on DataBase
        else {
            // Send setting update request to the backend
            updateSettings()
        }
    }
    
    // MARK: Private implementation
    
    // Send D4HThirdPartySettingsRequest to the Backend to update preferences
    private func updateSettings() {
        
        let password = TPEditSettings?.passwordTextField.text
        let companyName = TPEditSettings?.companyNameTextField.text
        let companyDescription = TPEditSettings?.companyDescriptionTextField.text
        
        NetworkManager.sharedInstance.sendPostRequest(input: D4HThirdPartySettingsRequest(password: password!, company_name: companyName!, company_description: companyDescription!), endpoint: D4HEndpoint.setInfoThirdParty, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HRegisterSingleResponse(fromJson: response!)
                print(myres.message)
                
                // Update labels
                self.TPViewSettings?.passwordLabel.text = (password?.isEmpty)! ? self.TPViewSettings?.passwordLabel.text : password
                self.TPViewSettings?.organisationNameLabel.text = (companyName?.isEmpty)! ? self.TPViewSettings?.organisationNameLabel.text : companyName
                self.TPViewSettings?.descriptionLabel.text = (companyDescription?.isEmpty)! ? self.TPViewSettings?.descriptionLabel.text : companyDescription
                
                // Exit from edit mode
                self.startEditing(self)
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
    private func loadinfo() {
        NetworkManager.sharedInstance.sendGetRequest(input: D4HThirdPartyInfoRequest(), endpoint: D4HEndpoint.setInfoThirdParty, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HThirdPartyInfoResponse(fromJson: response!)
                
                // Update Labels
                self.TPViewSettings?.fillView(info: myres)
            }
            else if let error = error {
                print(error)
            }
        }
    }

}
