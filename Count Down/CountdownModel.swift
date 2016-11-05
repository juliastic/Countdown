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
    static func storeCountdownDataInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext, notification: UILocalNotification, eventName: String, dateCreated: Date)
    static func saveContext(_ managedObjectContext: NSManagedObjectContext)
}

class CoredownModel: NSObject, CountDownModelProtocol {
    
    class func storeCountdownDataInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext, notification: UILocalNotification, eventName: String, dateCreated: Date) {
        let countdown = NSEntityDescription.insertNewObject(forEntityName: "Countdown", into: managedObjectContext) 

        countdown.setValue(dateCreated, forKey: "dateCreated")
        countdown.setValue(eventName, forKey: "countdownName")
        countdown.setValue(notification, forKey: "notification")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error saving context: \(error.localizedDescription)\n\(error.userInfo)")
        }
        
        CoredownModel.saveContext(managedObjectContext)
    }
    
    class func saveContext(_ managedObjectContext: NSManagedObjectContext) {
        let moc = managedObjectContext
        
        if !moc.hasChanges {
            return
        }
        
        do {
            try moc.save()
            return
        } catch let error as NSError {
            print("Error saving context: \(error.localizedDescription)\n\(error.userInfo)")
        }
        abort()
    }
}
