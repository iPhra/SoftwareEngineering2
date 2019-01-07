//
//  MyHealth.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class MyHealth: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var automatedSOSSwitch: UISwitch!

    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automatedSOSSwitch.setOn(DataManager.sharedInstance.getStoredAutomatedSOSValue(), animated: true)
        
        //Setup scroll view
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
   
    }
    
    @IBAction func toggleAutomatedSOSON(_ sender: Any) {
        DataManager.sharedInstance.toggleAutomatedSOS();
    }
    
}


