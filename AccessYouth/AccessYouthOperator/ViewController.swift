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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapView : MKMapView?
    let locationManager = CLLocationManager()
    let broadcastButton = UIButton()
    var isBroadcastOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        if let mapView = self.mapView {
            mapView.mapType = MKMapType.standard
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
            self.view.addSubview(mapView)
        }
        
        broadcastButtonSetup()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            print("Latitude: \(location.coordinate.latitude)")
//            print("Longitude: \(location.coordinate.longitude)")
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            if let mapView = self.mapView {
                mapView.setRegion(region, animated: true)
                mapView.showsUserLocation = true
            }
        }
    }
    
    func sendLocation(_ latitude: Double, _ longitude: Double) {
        // send location info to back-end
    }
    
    func broadcastButtonSetup() {
        broadcastButton.backgroundColor = Constants.Colors.purple
        broadcastButton.setTitleColor(.white, for: .normal)
        broadcastButton.setTitle(isBroadcastOn ? "Turn Off" : "Turn On", for: .normal)
        broadcastButton.layer.cornerRadius = 5.0
        broadcastButton.addTarget(self, action: #selector(self.changeBroadcastStatus), for: .touchUpInside)
        view.addSubview(broadcastButton)
        broadcastButtonConstraints()
    }
    
    func broadcastButtonConstraints() {
        broadcastButton.translatesAutoresizingMaskIntoConstraints = false
        broadcastButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25, constant: 0).isActive = true
        broadcastButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        broadcastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        broadcastButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
    }
    
    @objc func changeBroadcastStatus(sender : UIButton) {
        isBroadcastOn = isBroadcastOn ? false : true
        broadcastButton.setTitle(isBroadcastOn ? "Turn Off" : "Turn On", for: .normal)
        print("Button Tapped, now \(isBroadcastOn)")
    }
    
    func displayRequests() {
        
    }
    

}

