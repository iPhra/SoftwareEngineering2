//
//  MyHistory.swift
//  Data4Help
//
//  Created by Virginia Negri on 15/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class MyHistory: UIViewController {
    
    @IBOutlet weak var requestsContainer: UIView!

    var TPRequestsController: Data4Help.TPRequestsController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load child view controllers
        
        let storyboard = UIStoryboard(name: "ThirdParty", bundle: Bundle.main)
        
        // Instantiate View Controller
        let controller = storyboard.instantiateViewController(withIdentifier: "TPRequestsController") as! Data4Help.TPRequestsController
        
        self.TPRequestsController = controller
        
        //set current view controller
        
        addChild(controller)
        
        self.requestsContainer.addSubview(controller.view)
        
        controller.didMove(toParent: self)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
