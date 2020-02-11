//
//  TabBarController.swift
//  AccessYouthOperator
//
//  Created by Andi Xiong on 2019-11-02.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    let networking = Resolver.resolve(AccessNetworkOperator.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapVC = MapViewController()
        mapVC.tabBarItem = UITabBarItem(title: "Bus", image: UIImage(named: "busIcon"), tag: 0)

        let requestVC = UINavigationController(rootViewController: RequestViewController())
        requestVC.tabBarItem = UITabBarItem(title: "Requests", image: UIImage(named: "requestIcon"), tag: 1)

        let tabBarList = [mapVC, requestVC]
        self.viewControllers = tabBarList

        self.tabBar.tintColor = .white
        self.tabBar.unselectedItemTintColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "token") == nil {
            presentLoginAlert()
            return
        } else {
            // ping and check user token
            networking.accountDetails()
        }
    }

    /// - Precondition: Must be on the main thread
    func presentLoginAlert() {
        let loginAlert = UIAlertController(title: "Login", message: "Enter admin password", preferredStyle: .alert)
        loginAlert.addTextField { (usernameField) in
            usernameField.placeholder = "Username"
            usernameField.textContentType = .username
        }
        loginAlert.addTextField { (passwordField) in
            passwordField.isSecureTextEntry = true
            passwordField.placeholder = "Password"
            passwordField.textContentType = .password
        }
        loginAlert.addAction(UIAlertAction(title: "Enter", style: .default) { (_) in
            if let username = loginAlert.textFields?[0].text, let password = loginAlert.textFields?[1].text {
                networking.login(username: username, password: password) { (success) in
                    if !success {
                        DispatchQueue.main.async { [weak loginAlert] in
                            if let loginAlert = loginAlert {
                                self.present(loginAlert, animated: true)
                            }
                        }
                    }
                }
            }
        })
        present(loginAlert, animated: true)
    }
}
