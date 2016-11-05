//
//  calculationStruct.swift
//  Count Down
//
//  Created by Julia Grill on 07/06/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import Foundation
import UIKit

struct Calculation {
    
    static func calculateProgress(_ dateCreated: Date, fireDate: Date) -> String {
        let totalTimeInterval = fireDate.timeIntervalSince(dateCreated)
        let passedTimeInterval = Date().timeIntervalSince(dateCreated)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        return passedTimeInterval / totalTimeInterval * 100 <= 100 ? String.init(format: "%.2f", passedTimeInterval / totalTimeInterval * 100) + "%" : "completed"
    }
    
    static func countingDownToCountdown(_ endingDate: Date) -> String? {
        let converter = DateFormatter()
        converter.dateStyle = DateFormatter.Style.medium
        let countdownDateString = converter.string(from: endingDate)
        return countdownDateString.characters.count > 0 ? countdownDateString : nil
    }
    
    static func isCountdownFinished(_ fireDate: Date) -> Bool {
        let now = Date()
        return ((now as NSDate).earlierDate(fireDate) == fireDate)
    }
}
