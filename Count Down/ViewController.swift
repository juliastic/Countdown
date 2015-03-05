//
//  ViewController.swift
//  Count Down
//
//  Created by Julia Grill on 08/06/14.
//  Copyright (c) 2014 Julia Grill. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var eventDescriptionLabel : UILabel!
    @IBOutlet var daysLabel : UILabel!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var secondsLabel : UILabel!
    
    // MARK: Data Storage
    
    var managedObjectContext: NSManagedObjectContext?
    var countdownModel: CountDownModelProtocol?
    var pageViewController: UIPageViewController?
    
    var pageCountdown: NSDate!
    var pageString: String!
    var currentIndex = 0
    var updateLabelsTimer: NSTimer?
    var amountOfCountdowns = 1
    
    var countdownDate: NSDate? {
        didSet {
            updateLabelsTimer?.invalidate()
            updateLabelsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimeRemaining", userInfo: nil, repeats: true)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        
        var fetchRequestData = NSFetchRequest()
        var error: NSError? = nil
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext:managedObjectContext!)
        fetchRequestData.entity = entity
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var newDataAdded = defaults.boolForKey("newDataAdded")
        var countdownForKey = defaults.integerForKey("indexClicked")
        var countdownRow = countdownForKey
        
        if newDataAdded {
            var fetchedObjects = (managedObjectContext?.executeFetchRequest(fetchRequestData, error: &error) as [Countdown])
                var fetchedObject = fetchedObjects[countdownForKey]
                countdownDate = fetchedObject.notification.fireDate
                eventDescriptionLabel.text = fetchedObject.countdownName
                defaults.setBool(false, forKey: "newDataAdded")
        } else {
            countdownDate = pageCountdown//fetchedObject.notification.fireDate
            eventDescriptionLabel.text = pageString//fetchedObject.countdownName
        }
        
        updateTimeRemaining()
    }
    
    var switchBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "addNewCountdown" {
            let navigationController = segue.destinationViewController as UINavigationController
            let destinationVC = navigationController.topViewController as AddViewController
            destinationVC.managedObjectContext = managedObjectContext
        } else if segue.identifier == "showCountdowns" {
            var contentViewController = segue.destinationViewController as CountdownTableViewController
            contentViewController.managedObjectContext = managedObjectContext!
            
        }
    }
    
    func numberOfCountdowns() -> Int {
        var fetchRequestData = NSFetchRequest()
        var error: NSError? = nil
        
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext:managedObjectContext!)
        
        fetchRequestData.entity = entity
        var dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequestData.sortDescriptors = NSArray(object: dateSort)
        fetchRequestData.fetchLimit = 20
        
        var countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        fetchRequestData.sortDescriptors = NSArray(object: countdownNameSort)
        fetchRequestData.fetchLimit = 20
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        
        var fetchedObjects = (managedObjectContext!.executeFetchRequest(fetchRequestData, error:&error) as [Countdown])
        return fetchedObjects.count
    }
    
    func switchCountdown(sender: UISwipeGestureRecognizer) {
        var fetchRequestData = NSFetchRequest()
        var error: NSError? = nil
        
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext:managedObjectContext!)
        
        fetchRequestData.entity = entity
        var dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequestData.sortDescriptors = NSArray(object: dateSort)
        fetchRequestData.fetchLimit = 20
        
        var countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        fetchRequestData.sortDescriptors = NSArray(object: countdownNameSort)
        fetchRequestData.fetchLimit = 20
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        
        var fetchedObjects = (managedObjectContext!.executeFetchRequest(fetchRequestData, error:&error) as [Countdown])
        amountOfCountdowns = fetchedObjects.count
        
        if sender.direction == UISwipeGestureRecognizerDirection.Right && fetchedObjects.count != 0 {
            if currentIndex < fetchedObjects.count {
                currentIndex--
            }
        } else if sender.direction == UISwipeGestureRecognizerDirection.Left && fetchedObjects.count != 0 {
            if currentIndex >= 1 {
                currentIndex++
            }
        }
        
        if currentIndex < 0 {
            currentIndex = fetchedObjects.count-1
        } else if currentIndex >= fetchedObjects.count {
            currentIndex = 0
        }
        
        
        let selectedCountdown = fetchedObjects[currentIndex]
        let fireDate = selectedCountdown.notification.fireDate
        countdownDate = fireDate
    
        let countdownName = selectedCountdown.countdownName
        eventDescriptionLabel.text = countdownName
    }
    
    // MARK: Custom Methods
    
    var popOverBool = true
    
    func updateTimeRemaining() {
        let (days, hours, minutes, seconds) = TimeFormatter.calculateTime(NSDate(), fireDate: countdownDate!)
        daysLabel.text = "\(days)"
        hoursLabel.text = "\(hours)"
        minutesLabel.text = "\(minutes)"
        secondsLabel.text = "\(seconds)"
        
        // Check if countdown is finished
        if countdownDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending && popOverBool == true {
            var countdownOverAlert = UIAlertController(title: "Countdown over!", message: "This countdown is finished!", preferredStyle: UIAlertControllerStyle.Alert)
            countdownOverAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(countdownOverAlert, animated: true, completion: nil)
            popOverBool = false
        }
    }
}

