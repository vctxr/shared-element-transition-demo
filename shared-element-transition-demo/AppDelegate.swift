//
//  AppDelegate.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = FirstVC()
        window?.makeKeyAndVisible()
        return true
    }
}
