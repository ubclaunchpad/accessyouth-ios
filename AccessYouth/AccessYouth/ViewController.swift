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

    var accessNetwork: AccessNetwork = Resolver.resolve()
    var busAnnotations = [MKPointAnnotation]()

    static let buttonHeight: CGFloat = 50

    let mapView = MKMapView()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(BusAnnotationView.self, forAnnotationViewWithReuseIdentifier: "busMarkerAnnotationView")
        accessNetwork.fetchLocations(uuid: "b3f16201-51c4-4082-a859-fe8bec76466e", completion: plotBusLocations)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (_) in
            self.accessNetwork.fetchLocations(uuid: "b3f16201-51c4-4082-a859-fe8bec76466e", completion: self.plotBusLocations)
        }
    }

    override func loadView() {
        super.loadView()

        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        mapView.mapType = MKMapType.standard
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.delegate = self

        let drawer = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        drawer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawer)
        NSLayoutConstraint.activate([
            drawer.leftAnchor.constraint(equalTo: view.leftAnchor),
            drawer.rightAnchor.constraint(equalTo: view.rightAnchor),
            drawer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let requestBusButton = UIButton(type: .system)
        requestBusButton.backgroundColor = .systemBlue
        requestBusButton.setTitleColor(.white, for: .normal)
        requestBusButton.layer.cornerRadius = 10
        requestBusButton.setTitle("Request Bus", for: .normal)
        requestBusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        let callButton = UIButton(type: .system)
        callButton.backgroundColor = .systemBlue
        callButton.setTitleColor(.white, for: .normal)
        callButton.layer.cornerRadius = 10
        callButton.setTitle("Call Operator", for: .normal)
        callButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        let buttonsStackView = UIStackView(arrangedSubviews: [requestBusButton, callButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        drawer.contentView.addSubview(buttonsStackView)
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 10

        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: drawer.layoutMarginsGuide.topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: drawer.layoutMarginsGuide.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: drawer.layoutMarginsGuide.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: drawer.layoutMarginsGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: ViewController.buttonHeight),
        ])

        mapView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: view.safeAreaInsets.bottom + ViewController.buttonHeight + drawer.layoutMargins.top * 2, trailing: 0)
    }

    func plotBusLocations(_ locations: [CLLocationCoordinate2D]) {
        print("plotting locations: \(locations)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.busAnnotations.forEach(self.mapView.removeAnnotation)
            self.busAnnotations.removeAll()
            for index in 0..<locations.count {
                let location = locations[index]
                let busAnnotation = MKPointAnnotation()
                busAnnotation.title = index == 0 ? "Current Bus Location" : "Next Destination"
                busAnnotation.coordinate = location
                self.mapView.addAnnotation(busAnnotation)
                self.busAnnotations.append(busAnnotation)
                if index > 0 {
//                    self.plotDirections(source: locations[index - 1], destination: location)
                }
            }
//            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
/*
    func plotDirections(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = false

        let directions = MKDirections(request: directionRequest)

        directions.calculate { (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            if let route = response.routes.first {
                self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            }
        }
    }*/
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pointAnnotation = annotation as? MKPointAnnotation, busAnnotations.contains(pointAnnotation), let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "busMarkerAnnotationView", for: annotation) as? BusAnnotationView {
            annotationView.displayPriority = .required
            let index = busAnnotations.firstIndex(of: pointAnnotation) ?? 0
            annotationView.glyphText = index == 0 ? nil : "\(index)"
            return annotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(hue: CGFloat.random(in: 0.0..<1.0), saturation: 0.8, brightness: 0.8, alpha: 1.0)
        renderer.lineWidth = 3.0
        return renderer
    }
}

class BusAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        glyphImage = UIImage(named: "busIcon")!
        markerTintColor = Constants.Colors.purple
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
