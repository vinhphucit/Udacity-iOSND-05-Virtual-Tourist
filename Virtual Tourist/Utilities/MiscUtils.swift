//
//  MiscUtils.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation

struct MiscUtils {
    static func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - NetworkConstants.BBox.HalfWidth, NetworkConstants.BBox.LonRange.0)
        let minimumLat = max(latitude  - NetworkConstants.BBox.HalfHeight, NetworkConstants.BBox.LatRange.0)
        let maximumLon = min(longitude + NetworkConstants.BBox.HalfWidth, NetworkConstants.BBox.LonRange.1)
        let maximumLat = min(latitude  + NetworkConstants.BBox.HalfHeight, NetworkConstants.BBox.LatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
