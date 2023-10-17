//
//  ImageAndLocation.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import Foundation
import CoreLocation
import UIKit

class ImageAndLocation {
    
    let image:UIImage
    let location:CLLocationCoordinate2D
    
    init(image:UIImage, location:CLLocationCoordinate2D) {
        self.image = image
        self.location = location
    }
}
