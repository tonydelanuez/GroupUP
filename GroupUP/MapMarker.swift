//
//  MapMarker.swift
//  GroupUP
//
//  Created by Justin Guyton on 4/6/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import MapKit

class MapMarker : NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
