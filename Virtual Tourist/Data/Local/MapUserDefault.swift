//
//  MapUserDefault.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/11/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation
import MapKit
class MapUserDefault {
    struct Keys {
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let latitudeDelta: String = "latitudeDelta"
        static let longitudeDelta: String = "longitudeDelta"
    }
    
    func saveRegion(mapRegion: MKCoordinateRegion?) {
        if let mapRegion = mapRegion {
            UserDefaults.standard.set(mapRegion.center.latitude, forKey: Keys.latitude)
            UserDefaults.standard.set(mapRegion.center.longitude, forKey: Keys.longitude)
            UserDefaults.standard.set(mapRegion.span.latitudeDelta, forKey: Keys.latitudeDelta)
            UserDefaults.standard.set(mapRegion.span.longitudeDelta, forKey: Keys.longitudeDelta)

        }
    }
    
    func getMapRegion() -> MKCoordinateRegion? {
        if isKeyPresentInUserDefaults(key: Keys.latitude), isKeyPresentInUserDefaults(key: Keys.longitude),
            isKeyPresentInUserDefaults(key: Keys.latitudeDelta),isKeyPresentInUserDefaults(key: Keys.longitudeDelta) {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: Keys.latitude), longitude: UserDefaults.standard.double(forKey: Keys.longitude)),
                span: MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: Keys.latitudeDelta), longitudeDelta: UserDefaults.standard.double(forKey: Keys.longitudeDelta))
            )
        }
        
        return nil
        
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static let shared = MapUserDefault()
}
