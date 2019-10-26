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
        
        broadcastButton.backgroundColor = .purple
        broadcastButton.setTitleColor(.brown, for: .normal)
        broadcastButton.setTitle(isBroadcastOn ? "Turn Off" : "Turn On", for: .normal)
        broadcastButton.layer.borderColor = UIColor.black.cgColor
        broadcastButton.layer.cornerRadius = 2.0
        view.addSubview(broadcastButton)
        
        broadcastButtonConstraints()
        
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
            print("Latitude: \(location.coordinate.latitude)")
            print("Longitude: \(location.coordinate.longitude)")
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            if let mapView = self.mapView {
                mapView.setRegion(region, animated: true)
                mapView.showsUserLocation = true
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
        case .denied:
            print("user tap 'disallow' on the permission dialog, cant get location data")
        case .restricted:
            print("parental control setting disallow location data")
        default:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        }
    }
    
    func sendLocation(_ latitude: Double, _ longitude: Double) {
        // send location info to back-end
    }
    
    func broadcastButtonConstraints() {
        broadcastButton.translatesAutoresizingMaskIntoConstraints = false
        broadcastButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        broadcastButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        broadcastButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        broadcastButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }

}

