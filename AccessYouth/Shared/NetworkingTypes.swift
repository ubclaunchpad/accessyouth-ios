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

    init(location: CLLocationCoordinate2D) {
        lat = location.latitude
        lon = location.longitude
    }

    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
    let serviceType: ServiceType
    let currentLocation: LocationNetworkType
    let details: String
    let createdTime: Date
    let updatedTime: Date
    let deletedTime: Date
}

