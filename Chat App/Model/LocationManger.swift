//
//  LocationManger.swift
//  Chat Clone
//
//  Created by Mohammed on 27/01/2024.
//

import Foundation
import CoreLocation

class LocationManger: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManger()
    
    var locationManger: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    private override init () {
        super.init()
        requestLocationAccess()
    }
    
    func requestLocationAccess() {
        if locationManger == nil {
            locationManger = CLLocationManager()
            locationManger!.delegate = self
            locationManger!.desiredAccuracy = kCLLocationAccuracyBest
            locationManger!.requestWhenInUseAuthorization()
        } else {
            print("we have already location manger")
        }
    }
    
    
    func startUpdating() {
        locationManger!.startUpdatingHeading()
    }
    
    
    func stopUpdating() {
        if locationManger != nil {
            locationManger!.stopUpdatingLocation()
        }
    }
    
    //MARK:- Delegate function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("faild to get location", error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .notDetermined {
            self.locationManger!.requestWhenInUseAuthorization()
        }
    }
}


