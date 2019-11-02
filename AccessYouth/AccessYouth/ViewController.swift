//
//  ViewController.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2019-10-19.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    static let drawerHeight: CGFloat = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    override func loadView() {
        super.loadView()
        let mapView = MKMapView()
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: ViewController.drawerHeight, trailing: 0)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let drawer = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        drawer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawer)
        NSLayoutConstraint.activate([
            drawer.heightAnchor.constraint(equalToConstant: ViewController.drawerHeight),
            drawer.leftAnchor.constraint(equalTo: view.leftAnchor),
            drawer.rightAnchor.constraint(equalTo: view.rightAnchor),
            drawer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let mainTitle = UILabel()
        mainTitle.text = "Access Youth Client"
        mainTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        drawer.contentView.addSubview(mainTitle)
        NSLayoutConstraint.activate([
            mainTitle.centerXAnchor.constraint(equalTo: drawer.centerXAnchor),
            mainTitle.centerYAnchor.constraint(equalTo: drawer.centerYAnchor),
        ])
    }

}
