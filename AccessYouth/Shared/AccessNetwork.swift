//
//  AccessNetwork.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2019-10-26.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import Foundation
import CoreLocation

protocol AccessNetwork {
    func fetchLocations(completion: ([CLLocationCoordinate2D]) -> Void)
}

class AccessNetworkHTTP: AccessNetwork {
    let session: URLSession = URLSession(configuration: .default)

    static let baseURL = "localhost"

    func fetchLocations(completion: ([CLLocationCoordinate2D]) -> Void) {

    }
}

class AccessNetworkMock: AccessNetwork {
    func fetchLocations(completion: ([CLLocationCoordinate2D]) -> Void) {
        completion([
            CLLocationCoordinate2D(latitude: 49.2671283, longitude: -123.1485172),
            CLLocationCoordinate2D(latitude: 49.2475252, longitude: -123.1077016),
            CLLocationCoordinate2D(latitude: 49.2661433, longitude: -123.2458232),
        ])
    }
}

extension Resolver {
    static func registerNetworkServices() {
#if OFFLINE
        register { AccessNetworkMock() }.implements(AccessNetwork.self)
#else
        register { AccessNetworkHTTP() }.implements(AccessNetwork.self)
#endif
    }
}
