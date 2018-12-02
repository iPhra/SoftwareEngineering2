//
//  RequestViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 01/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit


class ResearchViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    var SRequest: Data4Help.SRequest? = nil
    var GRequest: Data4Help.GRequest? = nil
    var requestType = 0
    
    
    //MARK: functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load child view controllers
        
        let storyboard = UIStoryboard(name: "ThirdParty", bundle: Bundle.main)
        
        // Instantiate View Controller
        let controller = storyboard.instantiateViewController(withIdentifier: "SRequest") as! Data4Help.SRequest
        
        SRequest = controller
        
        let otherController = storyboard.instantiateViewController(withIdentifier: "GRequest") as! Data4Help.GRequest
        
        GRequest = otherController
        
        //set current view controller
        
        addChild(controller)
        
        viewContainer.addSubview(controller.view)
        
        controller.didMove(toParent: self)
    }
    
    @IBAction func ChangeRequest(_ sender: Any) {
        
        if(requestType==0){
            addChild(GRequest!)
            viewContainer.addSubview((GRequest?.view)!)
            requestType=1
        }
        else{
            addChild(SRequest!)
            viewContainer.addSubview((SRequest?.view)!)
            requestType=0
        }
    }
    
    
}


