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
    func fetchLocations(uuid: String, completion: @escaping ([CLLocationCoordinate2D]) -> Void)
    func getAllServices(completion: @escaping ([Service]) -> Void)
}

protocol AccessNetworkOperator {
    func operatorUpdateLocation(uuid: String, type: ServiceType, location: CLLocationCoordinate2D, details: String)
    func login(username: String, password: String, completion: @escaping (Bool) -> Void)
}

struct UpdateLocationNetworkType: Codable {
    let uuid: String
    let currentLocation: LocationNetworkType

    init(uuid: String, latitude: Double, longitude: Double) {
        self.uuid = uuid
        currentLocation = LocationNetworkType(lat: latitude, lon: longitude)
    }
}

struct LocationNetworkType: Codable {
    let lat: Double
    let lon: Double
}

struct UUIDNetworkType: Codable {
    let uuid: String
}

struct LoginNetworkType: Codable {
    let username: String
    let password: String
}

class AccessNetworkHTTP: AccessNetwork, AccessNetworkOperator {

    let session: URLSession = URLSession(configuration: .default)
    static let localhost = "192.168.0.11"
    static let baseURL = "http://app.accessyouth.org/api"

    private var tokenCache: String?

    var token: String? {
        get {
            if let token = tokenCache {
                return token
            } else if let token = UserDefaults.standard.string(forKey: "token") {
                tokenCache = token
                return token
            }
            return nil
        }
        set {
            if let token = newValue {
                tokenCache = token
                UserDefaults.standard.set(token, forKey: "token")
            }
        }
    }

    enum Endpoint {
        case updateLocation(location: UpdateLocationNetworkType)
        case fetchLocations(uuid: UUIDNetworkType)
        case getAllServices
        case login(username: String, password: String)

        var httpBody: Data? {
            switch self {
            case .updateLocation(let location):
                return try? JSONEncoder().encode(location)
            case .fetchLocations(let uuid):
                return try? JSONEncoder().encode(uuid)
            case .getAllServices:
                return nil
            case .login(let username, let password):
                return try? JSONEncoder().encode(LoginNetworkType(username: username, password: password))
            }
        }

        var url: URL {
            var requestURL = AccessNetworkHTTP.baseURL
            switch self {
            case .updateLocation:
                requestURL += "/service/updateLocation"
            case .fetchLocations:
                requestURL += "/service/getLocation"
            case .getAllServices:
                requestURL += "/service/getAllServices"
            case .login:
                requestURL += "/account/login"
            }
            guard let url = URL(string: requestURL) else {
                fatalError("Networking URL is not properly defined")
            }
            return url
        }

        var httpMethod: String {
            return "POST"
        }
    }

    func performNetworkRequest(endpoint: Endpoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = endpoint.url
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = endpoint.httpBody
        let dataTask = session.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }

    func fetchLocations(uuid: String, completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        performNetworkRequest(endpoint: .fetchLocations(uuid: UUIDNetworkType(uuid: uuid))) { (data, _, error) in
            guard let data = data, let location = try? JSONDecoder().decode(LocationNetworkType.self, from: data) else {
                print("error", error ?? "Unknown error")
                completion([])
                return
            }
            completion([CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)])
        }
    }

    func operatorUpdateLocation(uuid: String, type: ServiceType, location: CLLocationCoordinate2D, details: String) {
        let location = UpdateLocationNetworkType(uuid: uuid, latitude: location.latitude, longitude: location.longitude)
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

    func getAllServices(completion: @escaping ([Service]) -> Void) {

    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        performNetworkRequest(endpoint: .login(username: username, password: password)) { (data, response, error) in
            if let error = error {
                Log.error("Login error: \(error)")
                completion(false)
                return
            }
            guard let data = data, let dataString = String(data: data, encoding: .utf8) else {
                Log.error("Login error: no deserializable data received")
                completion(false)
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
                Log.error("Login error, response: \(dataString)")
                completion(false)
                return
            }
            self.token = dataString
            completion(true)
        }
    }

}

class AccessNetworkMock: AccessNetwork, AccessNetworkOperator {

    func operatorUpdateLocation(uuid: String, type: ServiceType, location: CLLocationCoordinate2D, details: String) {
    }

    func fetchLocations(uuid: String, completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        completion([
            CLLocationCoordinate2D(latitude: 49.2671283, longitude: -123.1485172),
//            CLLocationCoordinate2D(latitude: 49.2475252, longitude: -123.1077016),
//            CLLocationCoordinate2D(latitude: 49.2661433, longitude: -123.2458232),
        ])
    }

    func getAllServices(completion: @escaping ([Service]) -> Void) {
        completion([
            Service(
                uuid: "",
                serviceType: .bus,
                currentLocation: CLLocationCoordinate2D(latitude: 49.2671283, longitude: -123.1485172),
                details: "",
                createdTime: Date(),
                updatedTime: Date(),
                deletedTime: Date()),
        ])
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

extension Resolver {
    static func registerNetworkServices() {
#if OFFLINE
        register { AccessNetworkMock() }.implements(AccessNetwork.self)
        register { AccessNetworkMock() }.implements(AccessNetworkOperator.self)
#else
        register { AccessNetworkHTTP() }.implements(AccessNetwork.self)
        register { AccessNetworkHTTP() }.implements(AccessNetworkOperator.self)
#endif
    }
}
