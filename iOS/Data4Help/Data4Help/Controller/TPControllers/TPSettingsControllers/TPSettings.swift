//
//  TPSettings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPSettings: UIViewController {

    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    
    var TPViewSettings:TPViewSettings? = nil
    var TPEditSettings:TPEditSettings? = nil
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
    }
    
    @IBAction func startEditing(_ sender: Any) {
        if(edit==0){
            addChild(TPEditSettings!)
            containerView.addSubview((TPEditSettings?.view)!)
            edit = 1
            editButton.setTitle("Close",for: .normal)
        }
        else{
            addChild(TPViewSettings!)
            containerView.addSubview((TPViewSettings?.view)!)
            edit = 0
            editButton.setTitle("Edit",for: .normal)
        }
    }

}
