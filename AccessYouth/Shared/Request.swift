//
//  Request.swift
//  AccessYouth
//
//  Created by Andi Xiong on 2019-11-02.
//  Copyright © 2019 UBC Launch Pad. All rights reserved.
//

import Foundation
import CoreLocation

struct Request {
    // need confirmation to finalize fields
    let name: String?
    let location: CLLocationCoordinate2D?
    let message: String?
}
