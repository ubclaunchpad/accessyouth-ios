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
    /// Fetch account details
    func accountDetails()
}

/// Network result with decodable messages
enum NetworkResult<SuccessType: Codable, FailureType: Codable> {
    /// Network call success, with decoded value of the `data` field
    case success(response: HTTPURLResponse, value: SuccessType)
    /// Network call 4xx, with decoded value of the `data` field
    case failure(response: HTTPURLResponse, reason: FailureType)
    /// Network call failure
    case networkError(error: Error)
    /// Other non-networking issue - should never occur (fatal!)
    case otherError
}

class AccessNetworkHTTP: AccessNetwork, AccessNetworkOperator {

    let session: URLSession = URLSession(configuration: .default)
    static let baseURL = "http://app.accessyouth.org/api"
    static let userNeedsLoginNotification = Notification.Name("\(String(describing: AccessNetworkHTTP.self)).userNeedsLogin")
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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
        case accountDetails

        func encodedHttpBody(encoder: JSONEncoder) -> Data? {
            switch self {
            case .updateLocation(let location):
                return try? encoder.encode(location)
            case .fetchLocations(let uuid):
                return try? encoder.encode(uuid)
            case .getAllServices:
                return nil
            case .login(let username, let password):
                return try? encoder.encode(LoginNetworkType(username: username, password: password))
            case .accountDetails:
                return nil
            }
        }

        var url: URL {
            let requestURL = AccessNetworkHTTP.baseURL + {
                switch self {
                case .updateLocation:
                    return "/service/updateLocation"
                case .fetchLocations:
                    return "/service/getLocation"
                case .getAllServices:
                    return "/service/getAllServices"
                case .login:
                    return "/account/login"
                case .accountDetails:
                    return "/account/details"
                }
            }()

            guard let url = URL(string: requestURL) else {
                fatalError("Networking URL is not properly defined")
            }
            return url
        }

        var httpMethod: String {
            return "POST"
        }
    }

    /**
     * Perform a network request and automatically deserialize results based
     * on server response
     */
    func performNetworkRequest<SuccessType: Codable, FailureType: Codable>(
        endpoint: Endpoint,
        token: String? = nil,
        successType: SuccessType.Type,
        failureType: FailureType.Type,
        completion: @escaping (NetworkResult<SuccessType, FailureType>) -> Void
    ) {
        let url = endpoint.url
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.addValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = endpoint.encodedHttpBody(encoder: encoder)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Network error
                completion(.networkError(error: error))
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                // This shouldn't happen
                completion(.otherError)
                return
            }
            guard (200...299) ~= response.statusCode, let value = try? self.decoder.decode(successType, from: data) else {
                if let value = try? self.decoder.decode(failureType, from: data) {
                    completion(.failure(response: response, reason: value))
                }
                return
            }
            completion(.success(response: response, value: value))

        }
        dataTask.resume()
    }

    func performAuthenticatedNetworkRequest<SuccessType: Codable, FailureType: Codable>(
        endpoint: Endpoint,
        successType: SuccessType.Type,
        failureType: FailureType.Type,
        completion: @escaping (NetworkResult<SuccessType, FailureType>) -> Void
    ) {
        if let token = token {
            performNetworkRequest(endpoint: endpoint, token: token, successType: successType, failureType: failureType) { (result) in
                if case let .failure(response, reason) = result, response.statusCode == 401 {
                    // TODO: Do something for failed authentication
                    NotificationCenter.default.post(name: AccessNetworkHTTP.userNeedsLoginNotification, object: nil)
                }
                completion(result)
            }
        }
    }

    func fetchLocations(uuid: String, completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        performNetworkRequest(
            endpoint: .fetchLocations(uuid: UUIDNetworkType(uuid: uuid)),
            successType: LocationNetworkType.self,
            failureType: String.self
        ) { (result) in
            if case let .success(_, location) = result {
                Log.info("Fetch locations success")
                completion([CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)])
                return
            } else if case let .failure(_, reason) = result {
               Log.error("Fetch locations failure, \(reason)")
            } else if case let .networkError(error) = result {
               Log.error("Networking error on location fetch: \(error)")
            } else {
               Log.error("Other error on location fetch")
            }
            completion([])
        }
    }

    func operatorUpdateLocation(uuid: String, type: ServiceType, location: CLLocationCoordinate2D, details: String) {
        let location = UpdateLocationNetworkType(uuid: uuid, location: location)
        performNetworkRequest(endpoint: .updateLocation(location: location), successType: String.self, failureType: String.self) { (result) in
            if case let .success(_, response) = result {
                Log.info("Location update success, \(response)")
            } else if case let .failure(_, reason) = result {
                Log.error("Location update failure, \(reason)")
            } else if case let .networkError(error) = result {
                Log.error("Networking error on location update: \(error)")
            } else {
                Log.error("Other error on location update")
            }
        }
    }

    func getAllServices(completion: @escaping ([Service]) -> Void) {
        performNetworkRequest(endpoint: .getAllServices, successType: [ServiceNetworkType].self, failureType: String.self) { (result) in
            // TODO: handle error cases
            switch result {
            case let .success(_, value):
                completion(value.map(Service.init))
            default:
                completion([])
            }
        }
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        performNetworkRequest(endpoint: .login(username: username, password: password), successType: String.self, failureType: String.self) { (result) in
            if case let .success(_, token) = result {
                self.token = token
                completion(true)
                return
            }
            if case let .failure(_, reason) = result {
                Log.error("Login error, response: \(reason)")
            } else if case let .networkError(error) = result {
                Log.error("Login error: \(error)")
            } else {
                Log.error("Other error on login")
            }
            completion(false)
        }
    }

    func accountDetails() {
        performNetworkRequest(
            endpoint: .accountDetails,
            successType: String.self,
            failureType: String.self
        ) { (_) in }
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
                deletedTime: Date()
            ),
        ])
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func accountDetails() { }
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
