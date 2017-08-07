//
//  LocationConverter.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import MapKit

class LocationConverter {
    
    func locationConverter(location: CLLocation) {
        let geoCoder = CLGeocoder()
        let location = location
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDictionary = placemarks?[0].addressDictionary else { return }
            guard let city = addressDictionary["City"] as? String else { return }
            guard let country = addressDictionary["Country"] as? String else { return }
            print(city)
            print(country)
        })
    }
}
