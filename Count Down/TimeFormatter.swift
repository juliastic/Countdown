//
//  File.swift
//  Count Down
//
//  Created by Julia Grill on 14/09/2014.
//  Copyright (c) 2014 Julia Grill. All rights reserved.
//

import UIKit

struct TimeFormatter {
    
    static func secondsInDays(seconds: NSTimeInterval) -> Int {
        return secondsInHours(seconds) / 24
    }
    
    static func secondsInHours(seconds: NSTimeInterval) -> Int {
        return secondsInMinutes(seconds) / 60 // same as: seconds / (60.0 * 60.0), i.e. seconds
    }
    
    static func secondsInMinutes(seconds: NSTimeInterval) -> Int {
        return Int(seconds) / 60
    }
    
    static func secondsInSeconds(seconds: NSTimeInterval) -> Int {
        return Int(seconds) % 60
    }
    
    static func calculateTime(dateCreated: NSDate, fireDate: NSDate) -> (Int, Int, Int, Int) {
        var countdownTime = fireDate.timeIntervalSinceDate(dateCreated)
        var days = TimeFormatter.secondsInDays(countdownTime)
        var hours = TimeFormatter.secondsInHours(countdownTime) - TimeFormatter.secondsInDays(countdownTime) * 24
        var minutes = TimeFormatter.secondsInMinutes(countdownTime) - TimeFormatter.secondsInHours(countdownTime) * 60
        var seconds = TimeFormatter.secondsInSeconds(countdownTime)
        return (days, hours, minutes, seconds)
    }
}