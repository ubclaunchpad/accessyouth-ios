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

class AccessNetworkHTTP: AccessNetwork {
    let session: URLSession = URLSession(configuration: .default)
    static let localhost = "192.168.0.11"
    static let baseURL = "http://" + AccessNetworkHTTP.localhost + ":3001/api/service"
    static let opUpdateLocation = "/updateLocation"

    func fetchLocations(completion: ([CLLocationCoordinate2D]) -> Void) {

    }
    func operatorUpdateLocation(uuid: String, latitude: Double, longitude: Double) {
        let requestURL = AccessNetworkHTTP.baseURL + AccessNetworkHTTP.opUpdateLocation
        print(requestURL)
        let url = URL(string: requestURL)
        var request: URLRequest = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let parameters: [String: Any] = [
            "currentLocation": [latitude, longitude],
            "uuid": uuid,
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        // request.httpBody = parameters.percentEscaped().data(using: .utf8)
        let dataTask = session.dataTask(with: request) { data, response, error in
           guard let data = data,
               let response = response as? HTTPURLResponse,
               error == nil else {                                              // check for fundamental networking error
               print("error", error ?? "Unknown error")
               return
           }

           guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
               print("statusCode should be 2xx, but is \(response.statusCode)")
               print("response = \(response)")
               return
           }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        dataTask.resume()
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
