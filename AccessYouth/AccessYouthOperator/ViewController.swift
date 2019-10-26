//
//  ViewController.swift
//  AccessYouthOperator
//
//  Created by Yichen Cao on 2019-10-19.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapView : MKMapView?
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 100))
        mapView!.mapType = MKMapType.standard
        mapView!.isZoomEnabled = true
        mapView!.isScrollEnabled = true
        self.view.addSubview(self.mapView!)
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        if let locationManager = self.locationManager {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            print("R")
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let mapView = self.mapView {
            let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        }
    }
    func getCurrentLocation() {
        let locationStatus = CLLocationManager.authorizationStatus()
        if (locationStatus == .denied || locationStatus == .restricted || !CLLocationManager.locationServicesEnabled()) {
            let alert = UIAlertController(title: "Location Restricted", message: "Please go to settings and authorize location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if(locationStatus == .notDetermined){
            locationManager!.requestAlwaysAuthorization()
            return
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

}

