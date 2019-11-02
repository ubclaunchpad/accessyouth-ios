//
//  AccessNetwork.swift
//  AccessYouth
//
//  Created by Yichen Cao on 2019-10-26.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import Foundation

protocol AccessNetwork {
    func fetchLocations()
}

class AccessNetworkHTTP: AccessNetwork {
    static let shared: AccessNetwork = AccessNetworkHTTP()
    private init() { }

    let session: URLSession = URLSession(configuration: .default)

    static let baseURL = "localhost"

    func fetchLocations() {

    }
}
