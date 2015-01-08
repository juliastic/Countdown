//
//  Countdown.swift
//  CountDown
//
//  Created by Julia Grill on 08/01/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import Foundation
import CoreData

class Countdown: NSManagedObject {

    @NSManaged var countdownName: String
    @NSManaged var dateCreated: NSDate
    @NSManaged var notification: AnyObject

}
