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
    let serviceType: ServiceType
    let currentLocation: CLLocationCoordinate2D
    let details: String
    let createdTime: Date
    let updatedTime: Date
    let deletedTime: Date
}

extension Service {
    init(_ serviceNetworkType: ServiceNetworkType) {
        uuid = serviceNetworkType.uuid
        serviceType = serviceNetworkType.serviceType
        currentLocation = serviceNetworkType.currentLocation.clLocation
        details = serviceNetworkType.details
        createdTime = serviceNetworkType.createdTime
        updatedTime = serviceNetworkType.updatedTime
        deletedTime = serviceNetworkType.deletedTime
    }
}
