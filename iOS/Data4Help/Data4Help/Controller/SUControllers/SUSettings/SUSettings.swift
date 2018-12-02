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
    
    var ViewSettings:SUViewSettings? = nil
    var EditSettings:SUEditSettings? = nil
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
    }
    

    @IBAction func startEditing(_ sender: Any) {
        
        if(edit==0){
            addChild(EditSettings!)
            containerView.addSubview((EditSettings?.view)!)
            edit = 1
            editButton.setTitle("Close",for: .normal)
        }
        else{
            addChild(ViewSettings!)
            containerView.addSubview((ViewSettings?.view)!)
            edit = 0
            editButton.setTitle("Edit",for: .normal)
        }
    }
    

}
