//
//  Date.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation

extension Date {
    func compare(with creationDate: Date) -> AssetCreationDateCompareResult {
        let endTimeInterval = self.timeIntervalSince(creationDate)
        let day1 = Calendar.current.component(.day, from: self)
        let day2 = Calendar.current.component(.day, from: creationDate)
        
        if (abs(endTimeInterval) > SettingConstants.timeIntervalBoundary) && (day1 == day2) {
            return .differentIntervalBoundary
        } else if day1 != day2 {
            return .differentDate
        } else {
            return .containsIntervalboundaryAndDate
        }
    }
    
    func toDateString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        let languageCode = Locale.current.languageCode ?? Language.english
        
        switch languageCode {
        case Language.korean:
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        case Language.chinese, Language.japanese:
            dateFormatter.dateFormat = "yyyy年 MM月 dd日 EEEE"
        case Language.arabic:
            dateFormatter.dateFormat = "yyyy MM dd EEEE"
        default:
            dateFormatter.dateFormat = "E, d MMM yyyy"
        }
        
        return dateFormatter.string(from: self)
    }
}
