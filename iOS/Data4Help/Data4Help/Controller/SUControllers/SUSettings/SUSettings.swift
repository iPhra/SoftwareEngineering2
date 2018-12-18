//
//  Settings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class SUSettings: UIViewController {
    
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomActionButton: UIButton!
    
    var ViewSettings: SUViewSettings? = nil
    var EditSettings: SUEditSettings? = nil
    var edit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load child view controllers
        
        let storyboard = UIStoryboard(name: "SingleUser", bundle: Bundle.main)
        
        // Instantiate View Controller
        let controller = storyboard.instantiateViewController(withIdentifier: "SUViewSettings") as! Data4Help.SUViewSettings
        
        ViewSettings = controller
        
        let otherController = storyboard.instantiateViewController(withIdentifier: "SUEditSettings") as! Data4Help.SUEditSettings
        
        EditSettings = otherController
        
        //set current view controller
        
        addChild(controller)
        
        containerView.addSubview(controller.view)
        
        controller.didMove(toParent: self)
        
        // load user info
        loadinfo()
    }
    

    @IBAction func startEditing(_ sender: Any) {
        
        if(edit==0){
            addChild(EditSettings!)
            containerView.addSubview((EditSettings?.view)!)
            edit = 1
            editButton.setTitle("Close",for: .normal)
            bottomActionButton.setTitle("Save", for: .normal)
        }
        else{
            addChild(ViewSettings!)
            containerView.addSubview((ViewSettings?.view)!)
            edit = 0
            editButton.setTitle("Edit",for: .normal)
            bottomActionButton.setTitle("Logout", for: .normal)
        }
    }
    
    @IBAction func pressBottomButton(_ sender: UIButton) {
        // Logout and go back to Login View
        if (bottomActionButton.titleLabel?.text == "Logout") {
            // See implementation in Properties
            Properties.logout(controller: self)
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
        
        let fullname = EditSettings?.fullNameTextField.text
        let password = EditSettings?.passwordTextField.text
        let birthdate = EditSettings?.birthdateTextField.text

        NetworkManager.sharedInstance.sendPostRequest(input: D4HSingleUserSettingsRequest(password: password!, fullname: fullname!, birthdate: birthdate!), endpoint: D4HEndpoint.setInfoSingle, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HRegisterSingleResponse(fromJson: response!)
                print(myres.message)
                
                // Update Labels
                self.ViewSettings?.fullNameLabel.text = (fullname?.isEmpty)! ? self.ViewSettings?.fullNameLabel.text : fullname
                self.ViewSettings?.passwordLabel.text = (password?.isEmpty)! ? self.ViewSettings?.passwordLabel.text : password
                self.ViewSettings?.birthdateLabel.text = (birthdate?.isEmpty)! ? self.ViewSettings?.birthdateLabel.text : birthdate
                
                // Exit from edit view
                self.startEditing(self)
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
    private func loadinfo() {
        NetworkManager.sharedInstance.sendGetRequest(input: D4HSingleUserInfoRequest(), endpoint: D4HEndpoint.getInfoSingle, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HSingleUserInfoResponse(fromJson: response!)
                
                // Update Labels
                self.ViewSettings?.fillView(info: myres)
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
}
