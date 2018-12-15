//
//  AcceptedRequests.swift
//  Data4Help
//
//  Created by Virginia Negri on 13/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class SampleRequest{
    
    var status: String?
    var companyName: String?
    var datatypes: [dataType]?
    var subscribing: Bool?
    
    init(status: String, companyName: String, datatypes: [dataType], subscribing: Bool){
        self.status = status
        self.companyName = companyName
        self.datatypes = datatypes
        self.subscribing = subscribing
    }
}


class RequestsController: UITableViewController {
    
    // Mark: Properties
    
    var requests: [SampleRequest] = []
    var sections: [String] = []
    
    // Mark: Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        
        self.sections.append("Accepted Requests")
        self.sections.append("Pending Requests")
        self.sections.append("Refused Requests")
        
        let r: SampleRequest = SampleRequest(status: "accepted",companyName: "Company X", datatypes: [dataType.distanceWalkingRunning], subscribing: true)
        requests.append(r)

        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // Mark: - Table view data source
    
    func initRequest(){
        //initialize list of requests
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return self.sections[section]
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? MyCell  else {
            fatalError("The dequeued cell is not an instance of MyCell.")
        }
        
        let request = requests[indexPath.row]
        cell.initRequest(reqID: "", senderID: request.companyName!, types: request.datatypes!, subscribing: request.subscribing!, duration: 0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0;//Your custom row height
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
