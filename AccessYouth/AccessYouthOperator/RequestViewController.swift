//
//  RequestViewController.swift
//  AccessYouthOperator
//
//  Created by Andi Xiong on 2019-11-02.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RequestViewController: UIViewController {
    let requestTableView = UITableView()
    var requests: [Request]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Requests"

        setupRequests()
        requestTableViewSetup()
        requestTableView.dataSource = self
        requestTableView.delegate = self
        requestTableView.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")
    }

    func requestTableViewSetup() {
        view.addSubview(requestTableView)
        requestTableView.translatesAutoresizingMaskIntoConstraints = false
        requestTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        requestTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        requestTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        requestTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    func setUpNavigation() {
        navigationItem.title = "Requests"
        self.navigationController?.navigationBar.barTintColor = Constants.Colors.lightPurple
        self.navigationController?.navigationBar.isTranslucent = false
    }

    func setupRequests() {
        let r1 = Request(name: "123", location: CLLocationCoordinate2D(latitude: 40, longitude: 50), message: "hi")
        let r2 = Request(name: "456", location: CLLocationCoordinate2D(latitude: 40, longitude: 51), message: "hey")
        let r3 = Request(name: "7879", location: CLLocationCoordinate2D(latitude: 40, longitude: 50), message: "hi")
        let r4 = Request(name: "100000", location: CLLocationCoordinate2D(latitude: 40, longitude: 51), message: "hey")
        requests = [r1, r2, r3, r4]
    }

}

extension RequestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let requests = self.requests {
            return requests.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        cell.textLabel?.text = requests?[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = requests?[indexPath.row].message
        let alert = UIAlertController(title: "Approve this request?", message: message, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { (_) in
            Log.info("User clicked Approve button")
            // TODO: Approve request
        }))

        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { (_) in
            Log.info("User clicked Reject button")
            // TODO: Reject request
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            self.requestTableView.deselectRow(at: indexPath, animated: false)
        }))

        self.present(alert, animated: true)
    }

}
