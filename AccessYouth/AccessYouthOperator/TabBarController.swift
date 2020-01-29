//
//  TabBarController.swift
//  AccessYouthOperator
//
//  Created by Andi Xiong on 2019-11-02.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

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
}
