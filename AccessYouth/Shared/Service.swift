//
//  Service.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2020-01-18.
//  Copyright © 2020 UBC Launch Pad. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

enum ServiceType: String, Codable {
    case bus
}

struct Service {
    let uuid: String
    let name: String
    let serviceType: ServiceType
    let currentLocation: CLLocationCoordinate2D
    let description: String
    let createdAt: Date
    let updatedAt: Date
}

extension Service {
    init(_ serviceNetworkType: ServiceNetworkType) {
        uuid = serviceNetworkType.uuid
        name = serviceNetworkType.name
        serviceType = serviceNetworkType.serviceType
        currentLocation = serviceNetworkType.currentLocation.clLocation
        description = serviceNetworkType.description
        createdAt = serviceNetworkType.createdAt
        updatedAt = serviceNetworkType.updatedAt
    }
}
