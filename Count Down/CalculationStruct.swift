//
//  calculationStruct.swift
//  Count Down
//
//  Created by Julia Grill on 07/06/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import Foundation
import UIKit

struct CalculationStruct {
    
    static func calculateProgress(_ dateCreated: Date, fireDate: Date) -> String {
        let totalTimeInterval = fireDate.timeIntervalSince(dateCreated)
        let passedTimeInterval = Date().timeIntervalSince(dateCreated)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        if (passedTimeInterval / totalTimeInterval) * 100 <= 100 {
            return "\(numberFormatter.string(from: (passedTimeInterval / totalTimeInterval) * 100)!)%"
        } else {
            return "completed"
        }
    }
    
    static func countingDownToCountdown(_ endingDate: Date) -> String? {
        let converter = DateFormatter()
        converter.dateStyle = .mediumStyle
        let countdownDateString = converter.string(from: endingDate)
        if countdownDateString.characters.count > 0 {
            return countdownDateString
        } else {
            return nil
        }
    }
    
    static func isCountdownFinished(_ fireDate: Date) -> Bool {
        let now = Date()
        return ((now as NSDate).earlierDate(fireDate) == fireDate) ? true : false
    }
}
