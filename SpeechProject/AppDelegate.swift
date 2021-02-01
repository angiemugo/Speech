//
//  AppDelegate.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        let viewModel = ViewModel()
        let viewController = ViewController(viewModel)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

