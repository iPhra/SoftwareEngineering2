//
//  TPRequestsController.swift
//  Data4Help
//
//  Created by Virginia Negri on 15/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire

class TPRequestsController: UITableViewController, RequestCellDelegate {

    // MARK: Properties
    
    var singleRequests: [TPSingleRequest] = []
    var groupRequests: [TPGroupRequest] = []
    var sections: [String] = []
    
    // MARK: Outlets
    
    @IBOutlet var requestsTableView: UITableView!
    
    // Mark: Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        
        //SampleRequest(status: "accepted",companyName: "Company X", datatypes: [dataType.distanceWalkingRunning], subscribing: true)
        //requests.append(r)
        
        self.clearsSelectionOnViewWillAppear = false
        
        loadData()
    }
    
    // Mark: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleRequests.count + groupRequests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if (indexPath.row < singleRequests.count) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPRequestCell", for: indexPath) as? TPRequestCell  else {
                fatalError("The dequeued cell is not an instance of TPRequestCell.")
            }
            let request = singleRequests[indexPath.row]
            cell.initRequest(reqid: request.reqid, user: request.full_name, types: request.types, subscribing: request.subscribing, duration: Float(request.duration), date: request.date)
            cell.delegate = self
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPGroupRequestCell", for: indexPath) as? TPGroupRequestCell  else {
                fatalError("The dequeued cell is not an instance of TPGroupRequestCell.")
            }
            // TODO implement this part
            let request = groupRequests[indexPath.row - singleRequests.count]
            cell.initRequest(reqid: request.reqid, groupname: ("Group " + String(indexPath.row - singleRequests.count)), types: request.types, filters: request.parameters, subscribing: request.subscribing, duration: Float(request.duration), date: request.date)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0;//Your custom row height
    }
    
    // MARK: Private implementation
    
    func loadData() {
        // API call to retrieve requests
        NetworkManager.sharedInstance.sendGetRequest(input: D4HThirdPartyListRequest(authToken: Properties.authToken), endpoint: D4HEndpoint.requestListThirdParty, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HThirdPartyListResponse(fromJson: response!)
                self.singleRequests = myres.singleRequests
                self.groupRequests = myres.groupRequests
                // Debug
                print(self.singleRequests.count)
                self.requestsTableView.reloadData()
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
    func saveCSVgroup(reqid: String) {
        // API call to download request data
        NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadGroupRequest(reqID: reqid), endpoint: D4HEndpoint.downloadGroupRequest, headers: Properties.auth()) { (response, error) in
         if response != nil {
         let myres = D4HDownloadGroupResponse(fromJson: response!)
            // Show download action
            let vc = UIActivityViewController(activityItems: [myres.path], applicationActivities: [])
             /*vc.excludedActivityTypes = [
             UIActivity.ActivityType.assignToContact,
             UIActivity.ActivityType.saveToCameraRoll,
             UIActivity.ActivityType.postToFlickr,
             UIActivity.ActivityType.postToVimeo,
             UIActivity.ActivityType.postToTencentWeibo,
             UIActivity.ActivityType.postToTwitter,
             UIActivity.ActivityType.postToFacebook,
             UIActivity.ActivityType.openInIBooks
             ]*/
            self.present(vc, animated: true, completion: nil)
         }
         else if let error = error {
            print(error)
            }
         }
    }
    
    func saveCSVsingle(reqid: String) {
        // API call to download request data
        NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadSingleRequest(reqID: reqid), endpoint: D4HEndpoint.downloadSingleRequest, headers: Properties.auth()) { (response, error) in
         if response != nil {
         let myres = D4HDownloadSingleResponse(fromJson: response!)
         // Show download action
         let vc = UIActivityViewController(activityItems: [myres.path], applicationActivities: [])
         /*vc.excludedActivityTypes = [
         UIActivity.ActivityType.assignToContact,
         UIActivity.ActivityType.saveToCameraRoll,
         UIActivity.ActivityType.postToFlickr,
         UIActivity.ActivityType.postToVimeo,
         UIActivity.ActivityType.postToTencentWeibo,
         UIActivity.ActivityType.postToTwitter,
         UIActivity.ActivityType.postToFacebook,
         UIActivity.ActivityType.openInIBooks
         ]*/
         self.present(vc, animated: true, completion: nil)
         }
         else if let error = error {
         print(error)
         }
         }

    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
