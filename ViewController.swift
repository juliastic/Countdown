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
    
    var currentIndex = 0
    var updateLabelsTimer: NSTimer?
    
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
        
        var fetchedObjects = (managedObjectContext?.executeFetchRequest(fetchRequestData, error: &error) as [Countdown])
        
        if fetchedObjects.count < 1 {
            return
        }
        
        var fetchedObject = fetchedObjects[countdownRow]
            countdownDate = fetchedObject.notification.fireDate
            eventDescriptionLabel.text = fetchedObject.countdownName
        updateTimeRemaining()
    }
    
    var switchBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "switchCountdown:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "switchCountdown:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "createNewCountdown" {
            var destinationVC = segue.destinationViewController as AddTableViewController
            destinationVC.managedObjectContext = managedObjectContext
        } else if segue.identifier == "showCountdowns" {
            var contentViewController = segue.destinationViewController as CountdownTableViewController
          //  contentViewController.delegate = self
            contentViewController.managedObjectContext = managedObjectContext!
            
        }
    }
    
    
    func switchCountdown(sender: UISwipeGestureRecognizer) {
        var fetchRequestDate = NSFetchRequest()
        var error: NSError? = nil
        
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext:managedObjectContext!)
        
        fetchRequestDate.entity = entity
        var dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequestDate.sortDescriptors = NSArray(object: dateSort)
        fetchRequestDate.fetchLimit = 20
        
        var countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        fetchRequestDate.sortDescriptors = NSArray(object: countdownNameSort)
        fetchRequestDate.fetchLimit = 20
        
        fetchRequestDate.sortDescriptors = [dateSort, countdownNameSort]
        
        var fetchedObjects = (managedObjectContext!.executeFetchRequest(fetchRequestDate, error:&error) as [Countdown])
        
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
            // countdownDate is earlier than now
            updateLabelsTimer?.invalidate()
            // Show alert that countdown is done
            var countdownOverAlert = UIAlertController(title: "Countdown over!", message: "Your countdown \(eventDescriptionLabel.text) is finished", preferredStyle: UIAlertControllerStyle.Alert)
            countdownOverAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(countdownOverAlert, animated: true, completion: nil)
            popOverBool = false
        }
    }
}

