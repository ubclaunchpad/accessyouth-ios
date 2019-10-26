//
//  AppDelegate.swift
//  AccessYouthOperator
//
//  Created by Yichen Cao on 2019-10-19.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        print("in delegate")
        let homeViewController = ViewController()
        homeViewController.view.backgroundColor = UIColor.white
        window!.rootViewController = homeViewController
        window!.makeKeyAndVisible()
        return true
    }


}

