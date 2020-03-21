//
//  NetworkingTypes.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2020-02-10.
//  Copyright © 2020 UBC Launch Pad. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

struct UpdateLocationNetworkType: Codable {
    let uuid: String
    let currentLocation: LocationNetworkType

    init(uuid: String, location: CLLocationCoordinate2D) {
        self.uuid = uuid
        currentLocation = LocationNetworkType(location: location)
    }
}

struct LocationNetworkType: Codable {
    let lat: Double
    let lon: Double

    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension LocationNetworkType {
    init(location: CLLocationCoordinate2D) {
        lat = location.latitude
        lon = location.longitude
    }
}

struct UUIDNetworkType: Codable {
    let uuid: String
}

struct LoginNetworkType: Codable {
    let username: String
    let password: String
}

struct ServiceNetworkType: Codable {
    let uuid: String
    let name: String
    let serviceType: ServiceType
    let currentLocation: LocationNetworkType
    let description: String
    let createdAt: Date
    let updatedAt: Date
}
