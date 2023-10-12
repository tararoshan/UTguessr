//
//  ImageAndLocation.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import Foundation
import CoreLocation

class ImageAndLocation {
    
    let image:String
    let location:CLLocationCoordinate2D
    
    init(image:String, location:CLLocationCoordinate2D) {
        self.image = image
        self.location = location
    }
}
