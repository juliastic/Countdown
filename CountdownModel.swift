//
//  CountdownModel.swift
//  Count Down
//
//  Created by Julia Grill on 11/06/14.
//  Copyright (c) 2014 Julia Grill. All rights reserved.
//

import UIKit
import CoreData

protocol CountDownModelProtocol {
    class func storeCountdownDataInManagedObjectContext(managedObjectContext: NSManagedObjectContext, notification: UILocalNotification, eventName: String, dateCreated: NSDate)
    class func saveContext(managedObjectContext: NSManagedObjectContext)
}

class CoredownModel: NSObject, CountDownModelProtocol {
    
    class func storeCountdownDataInManagedObjectContext(managedObjectContext: NSManagedObjectContext, notification: UILocalNotification, eventName: String, dateCreated: NSDate) {
        var countdown = NSEntityDescription.insertNewObjectForEntityForName("Countdown", inManagedObjectContext: managedObjectContext) as NSManagedObject

        countdown.setValue(dateCreated, forKey: "dateCreated")
        countdown.setValue(eventName, forKey: "countdownName")
        countdown.setValue(notification, forKey: "notification")
        
        CoredownModel.saveContext(managedObjectContext)
    }
    
    class func saveContext(managedObjectContext: NSManagedObjectContext) {
        var error: NSError? = nil
        let moc = managedObjectContext
        if moc == 0 {
            return
        }
        if !moc.hasChanges {
            return
        }
        
        if moc.save(&error) {
            return
        }
        
        println("Error saving context: \(error?.localizedDescription)\n\(error?.userInfo)")
        abort()
    }
}