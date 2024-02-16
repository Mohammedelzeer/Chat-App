//
//  MapAnnotation.swift
//  Chat Clone
//
//  Created by Mohammed on 27/01/2024.
//

import Foundation
import MapKit


class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.coordinate = coordinate
    }
}
