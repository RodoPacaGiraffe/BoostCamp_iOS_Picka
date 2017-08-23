//
//  Int.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 23..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation

extension Int {
    func toArabic() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "ar")
        
        let arabicNumber = numberFormatter.string(from: NSNumber(value: self))
            ?? String(stringInterpolationSegment: self)
        
        return arabicNumber
    }
}
