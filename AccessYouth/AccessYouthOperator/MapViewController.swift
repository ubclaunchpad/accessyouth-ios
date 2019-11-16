//
//  ViewController.swift
//  AccessYouthOperator
//
//  Created by Yichen Cao on 2019-10-19.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class MapViewController: UIViewController {
    let locationManager = CLLocationManager()
    let broadcastButton = UIButton()
    var mapView: MKMapView?
    var timerSend: Timer?
    var timerFetch: Timer?
    var busLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var isBroadcastOn = false
    let broadcastInterval: Double = 1.0
    var accessNetwork: AccessNetwork = Resolver.resolve()
    var userLocations: [CLLocationCoordinate2D] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        // set up mapview
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width,
                                               height: view.frame.size.height))
        if let mapView = self.mapView {
            mapView.mapType = MKMapType.standard
            mapView.showsUserLocation = true
            let region = MKCoordinateRegion(center: busLocation, span:
                MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
            self.view.addSubview(mapView)
        }

        // set up button to turn on/off location broadcast of bus location
        broadcastButtonSetup()

        // request location access and start updating
        locationManagerSetup()

        // set up timer to poll for location at a fixed interval
        timerSend = Timer.scheduledTimer(timeInterval: broadcastInterval, target: self, selector: #selector(sendLocation), userInfo: nil, repeats: true)
        timerFetch = Timer.scheduledTimer(timeInterval: broadcastInterval, target: self, selector: #selector(fetchLocation), userInfo: nil, repeats: true)
    }

    func broadcastButtonSetup() {
        broadcastButton.backgroundColor = Constants.Colors.purple
        broadcastButton.setTitleColor(.white, for: .normal)
        broadcastButton.setTitle(isBroadcastOn ? "Turn Off" : "Turn On", for: .normal)
        broadcastButton.layer.cornerRadius = 5.0
        broadcastButton.addTarget(self, action: #selector(self.changeBroadcastStatus), for: .touchUpInside)
        view.addSubview(broadcastButton)
        broadcastButton.translatesAutoresizingMaskIntoConstraints = false
        broadcastButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25, constant: 0).isActive = true
        broadcastButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        broadcastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        broadcastButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
    }

    @objc func changeBroadcastStatus(sender: UIButton) {
        isBroadcastOn = isBroadcastOn ? false : true
        broadcastButton.setTitle(isBroadcastOn ? "Turn Off" : "Turn On", for: .normal)
        print("Button Tapped, now \(isBroadcastOn)")
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerSetup() {
        // request location access
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            busLocation = location.coordinate
            if let mapView = self.mapView {
                let region = MKCoordinateRegion(center: busLocation, span: mapView.region.span)
                mapView.setRegion(region, animated: true)
            }
        }
    }

    @objc func sendLocation() {
        if isBroadcastOn {
            // send location to backend
            print("Latitude: \(busLocation.latitude)\nLongitude: \(busLocation.longitude)")
            // hardcoded now since getting a list of available uuid is 
            let uuid = "12345"
            self.accessNetwork.operatorUpdateLocation(uuid: uuid, latitude: busLocation.latitude, longitude: busLocation.longitude)
        }
    }
    
    @objc func fetchLocation() {
//        accessNetwork.fetchLocations(completion: userLocations)
    }
}
