//
//  SpeedAnnotation.swift
//  TrackMyTrip
//
//  Created by 121outsource on 04/11/19.
//  Copyright © 2019 AshishKumar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum ColorType {
    case twenty
    case thirty
    case fifty
    case eighty
    case hundred
    case onetwenty
    case onefifty
    case twohundred
    case extra
}

class SpeedAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
        var title: String?
        var type: ColorType
    init(coordinate:CLLocationCoordinate2D,title:String,type:ColorType){
            self.coordinate = coordinate
            self.title = title
            self.type = type
        }
    
}
