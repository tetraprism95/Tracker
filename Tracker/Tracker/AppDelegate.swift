//
//  AppDelegate.swift
//  Tracker
//
//  Created by Nuri Chun on 9/15/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let mapController = MapController()
        let mapNavController = UINavigationController(rootViewController: mapController)
        
        window?.rootViewController = mapNavController
        window?.makeKeyAndVisible()
        
        return true
    }

}
