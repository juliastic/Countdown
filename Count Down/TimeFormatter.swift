//
//  TimeFormatter.swift
//  Count Down
//
//  Created by Julia Grill on 14/09/2014.
//  Copyright (c) 2014 Julia Grill. All rights reserved.
//

import UIKit

struct TimeFormatter {
    
    static func secondsInDays(_ seconds: TimeInterval) -> Int {
        return secondsInHours(seconds) / 24
    }
    
    static func secondsInHours(_ seconds: TimeInterval) -> Int {
        return secondsInMinutes(seconds) / 60
    }
    
    static func secondsInMinutes(_ seconds: TimeInterval) -> Int {
        return Int(seconds) / 60
    }
    
    static func secondsInSeconds(_ seconds: TimeInterval) -> Int {
        return Int(seconds) % 60
    }
    
    static func calculateTime(_ dateCreated: Date, fireDate: Date) -> (Int, Int, Int, Int) {
        let countdownTime = fireDate.timeIntervalSince(dateCreated)
        let days = secondsInDays(countdownTime)
        let hours = secondsInHours(countdownTime) - secondsInDays(countdownTime) * 24
        let minutes = secondsInMinutes(countdownTime) - secondsInHours(countdownTime) * 60
        let seconds = secondsInSeconds(countdownTime)
        return (days, hours, minutes, seconds)
    }
}
