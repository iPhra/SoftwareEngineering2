//
//  MyFollowers.swift
//  Data4Help
//
//  Created by Virginia Negri on 13/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit




class MyFollowers: UIViewController {

    @IBOutlet weak var acceptedRequestsContainer: UIView!
    
    var RequestsController: Data4Help.RequestsController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load child view controllers
        
        let storyboard = UIStoryboard(name: "SingleUser", bundle: Bundle.main)
        
        // Instantiate View Controller
        let controller = storyboard.instantiateViewController(withIdentifier: "RequestsController") as! Data4Help.RequestsController
        
        self.RequestsController = controller
        
        //set current view controller
        
        addChild(controller)
        
        acceptedRequestsContainer.addSubview(controller.view)
        
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
