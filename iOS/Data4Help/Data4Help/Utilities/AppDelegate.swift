//
//  AppDelegate.swift
//  Data4Help
//
//  Created by Virginia Negri on 26/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Mark: Properties
    
    var window: UIWindow?
    
    var launchedShortcutItem: UIApplicationShortcutItem?
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    // Mark: Shared instance
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // Mark: Functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Data manager initializers
                
        DataManager.sharedInstance.authorizeHKinApp()
        DataManager.sharedInstance.storeBiologicalSex()
        
        //DataManager.sharedInstance.initTimer()
        
        // Storage manager initializers
            
        
        //Clean all data for debugging
        StorageManager.sharedInstance.deleteAllData(entityName: "Data")
        StorageManager.sharedInstance.deleteAllData(entityName: "AutomatedSOS")
                
        StorageManager.sharedInstance.initAutomatedSOS()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let shortcutItem = self.launchedShortcutItem else {return}
        
        _ = handleShortcutItem(item: shortcutItem)
        
        launchedShortcutItem = nil
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("Application will be closed")
        //LOG OUT
        NetworkManager.sharedInstance.sendPostRequest(input: D4HLogoutRequest(authToken: Properties.authToken), endpoint: D4HEndpoint.logout, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HLogoutResponse(fromJson: response!)
                // Reset authToken
                AppDelegate.deleteAllQuickShortcuts()
                Properties.logout()
                print(myres.message)
            }
            else if let error = error {
                print(error)
            }
        }
        
    }
    
    // Mark: Shortcut handlers
    
    static func deleteAllQuickShortcuts(){
        UIApplication.shared.shortcutItems?.removeAll()
    }
    
    /*
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void){
        
        if shortcutItem.type == "com.lorenzomolteninegri.Data4Help.automatedSOS"{
            completionHandler(handleShortcutItem(item: shortcutItem))
        }
    }
    */
    
    func handleShortcutItem(item: UIApplicationShortcutItem) -> Bool {
        DataManager.sharedInstance.enableAutomatedSOS()
        return true
    }
    
    // Mark: First data import handler
    
    func firstImport(){
        let sampleTypes = DataManager.sharedInstance.sampleTypesToRead()
        for sample in sampleTypes {
            DataManager.sharedInstance.enableBackgroundData(input: sample, datatype: DataManager.sharedInstance.getDataTypeFromSampleType(hkSampleType: sample))
        }
        DataManager.sharedInstance.initTimer() // send data
    }
    
}


