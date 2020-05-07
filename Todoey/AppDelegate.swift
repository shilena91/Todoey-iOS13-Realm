//
//  AppDelegate.swift
//  Todoey
//
//  Created by Hoang Pham on 01/05/2020.

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
    
        }
        catch {
            print("Error initializing new realm: \(error)")
        }
        
        return true
    }
    
}
