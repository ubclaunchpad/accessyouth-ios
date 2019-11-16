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
    func operatorUpdateLocation(uuid: String, latitude: Double, longitude: Double)
}

struct UpdateLocationNetworkType: Codable {
    let uuid: String
    let currentLocation: LocationNetworkType

    init(uuid: String, latitude: Double, longitude: Double) {
        self.uuid = uuid
        currentLocation = LocationNetworkType(latitude: latitude, longitude: longitude)
    }
}

struct LocationNetworkType: Codable {
    let latitude: Double
    let longitude: Double
}

class AccessNetworkHTTP: AccessNetwork {
    let session: URLSession = URLSession(configuration: .default)
    static let localhost = "192.168.0.11"
    static let baseURL = "http://" + AccessNetworkHTTP.localhost + ":3001/api/service"

    enum Endpoint {
        case updateLocation(location: UpdateLocationNetworkType)
        case fetchLocations

        var httpBody: Data? {
            switch self {
            case .updateLocation(let location):
                return try? JSONEncoder().encode(location)
            case .fetchLocations:
                return Data()
            }
        }

        var url: URL {
            var requestURL = AccessNetworkHTTP.baseURL
            switch self {
            case .updateLocation:
                requestURL += "/updateLocation"
            case .fetchLocations:
                requestURL += "/fetchLocations"
            }
            guard let url = URL(string: requestURL) else {
                fatalError("Networking URL is not properly defined")
            }
            return url
        }

        var httpMethod: String {
            switch self {
            case .updateLocation:
                return "POST"
            case .fetchLocations:
                return "GET"
            }
        }
    }

    func performNetworkRequest(endpoint: Endpoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = endpoint.url
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = endpoint.httpBody
        let dataTask = session.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }

    func fetchLocations(completion: ([CLLocationCoordinate2D]) -> Void) {

    }

    func operatorUpdateLocation(uuid: String, latitude: Double, longitude: Double) {
        let location = UpdateLocationNetworkType(uuid: uuid, latitude: latitude, longitude: longitude)
        performNetworkRequest(endpoint: .updateLocation(location: location)) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
    }

}

class AccessNetworkMock: AccessNetwork {
    func operatorUpdateLocation(uuid: String, latitude: Double, longitude: Double) {
    }

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
