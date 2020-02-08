//
//  Service.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2020-01-18.
//  Copyright © 2020 UBC Launch Pad. All rights reserved.
//

import Foundation
import CoreLocation

enum ServiceType: String {
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
