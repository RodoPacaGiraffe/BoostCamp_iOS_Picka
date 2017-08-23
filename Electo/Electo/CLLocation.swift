//
//  CLLocation.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    func reverseGeocode(completion: @escaping (_ locationString: String) -> Void) {
        let geoCoder = CLGeocoder()
        var locationString: String = ""
        
        geoCoder.reverseGeocodeLocation(self, completionHandler: { placemarks, error in
            guard let addressDictionary = placemarks?[0].addressDictionary else { return }
            guard let country = addressDictionary[LocationKey.country.rawValue] as? String else { return }
            guard let city = addressDictionary[LocationKey.city.rawValue] as? String else { return }
            
            locationString = "\(country) \(city)"
            
            completion(locationString)
        })
        
    }
}
