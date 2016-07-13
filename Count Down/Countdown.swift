//
//  Countdown.swift
//  Count Down
//
//  Created by Julia Grill on 06/01/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import Foundation
import CoreData

class Countdown: NSManagedObject {

    @NSManaged var notification: AnyObject
    @NSManaged var countdownName: String
    @NSManaged var dateCreated: Date

}
