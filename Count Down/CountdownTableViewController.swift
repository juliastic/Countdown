//
//  CountdownTableViewController.swift
//  Count Down
//
//  Created by Julia Grill on 03/01/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import UIKit
import CoreData

class CountdownTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext?
    var updateCellContentsTimer: NSTimer!
    var emptyStateLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        navigationItem.leftBarButtonItem?.title = nil
    }

    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.reloadData()
        updateCells()
        updateCellContentsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCells", userInfo: nil, repeats: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionsArray = fetchedResultsController.sections
        let numberOfObjectsInSections = sectionsArray![section].numberOfObjects
        emptyStateLabel = NSBundle.mainBundle().loadNibNamed("EmptyState", owner: self, options: nil)[0] as UILabel
        if numberOfObjectsInSections == 0 {
            defaults.setBool(false, forKey: "newDataAdded")
            updateCellContentsTimer?.invalidate()
            if (view.subviews as NSArray).containsObject(emptyStateLabel) == false {
                emptyStateLabel.center = CGPointMake(view.center.x, view.center.y - 100)
                view.addSubview(emptyStateLabel)
            }
        } else {
            emptyStateLabel?.removeFromSuperview()
        }
        return numberOfObjectsInSections
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "addVC" {
            let navigationController = segue.destinationViewController as UINavigationController
            let destinationVC = navigationController.topViewController as AddViewController
            destinationVC.managedObjectContext = managedObjectContext!
        } else if segue.identifier == "viewVC" {
            let navigationController = segue.destinationViewController as UINavigationController
            var destinationVC = navigationController.topViewController as ContentViewController
            destinationVC.countdownArray = fetchedResultsController.fetchedObjects as [Countdown]
            destinationVC.managedObjectContext = managedObjectContext
        }
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView!.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CountdownTableViewCell
        let (notification, eventName, dateCreated) = countdownDataAtIndexPath(indexPath)
        let now = NSDate()
        
        let differentColors = [UIColor(red: 10.0, green: 10.0, blue: 10.0, alpha: 1), UIColor.blueColor(), UIColor.redColor()]
        let randomIndex = Int(arc4random_uniform(UInt32(differentColors.count)))
        let randomBackgroundColor = differentColors[randomIndex]
        
        if eventName != nil {
            let progress = calculateProgress(dateCreated!, fireDate: notification!.fireDate!)
            let countdown = TimeFormatter.calculateTime(now, fireDate: notification!.fireDate!)
            cell.countdownName.text = eventName! + "\n" + countingDownToCountdown(notification!.fireDate!)
            cell.countdownName.backgroundColor = randomBackgroundColor
            cell.timeLeftLabel.text = progress + "% \n \(countdown.0):\(countdown.1):\(countdown.2):\(countdown.3)"
            
        }
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "deleteAction:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        cell.addGestureRecognizer(swipeLeft)
        cell.backgroundColor = randomBackgroundColor
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defaults.setInteger(indexPath.row, forKey: "indexClicked")
        defaults.setBool(true, forKey: "newDataAdded")
    }
    
    func calculateProgress(dateCreated: NSDate, fireDate: NSDate) -> String {
        var totalTimeInterval = fireDate.timeIntervalSinceDate(dateCreated)
        let passedTimeInterval = NSDate().timeIntervalSinceDate(dateCreated)
        
        var numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.maximumFractionDigits = 2
        
        if (passedTimeInterval / totalTimeInterval) * 100 <= 100 {
            return numberFormatter.stringFromNumber((passedTimeInterval / totalTimeInterval) * 100)!
        } else {
            return "> 100"
        }
    }
    
    func updateCells () {
        var indexPathsArray = tableView.indexPathsForVisibleRows() as Array<NSIndexPath>
        for indexPath in indexPathsArray {
            let cell = tableView!.cellForRowAtIndexPath(indexPath) as CountdownTableViewCell
            let (notification, eventName, dateCreated) = countdownDataAtIndexPath(indexPath)
            var now = NSDate()
            if now.earlierDate(notification!.fireDate!).isEqualToDate(notification!.fireDate!) {
                //could add an image
            }
            
            let progress = calculateProgress(dateCreated!, fireDate: notification!.fireDate!)
            let countdown = TimeFormatter.calculateTime(now, fireDate: notification!.fireDate!)
            
            var numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            numberFormatter.maximumFractionDigits = 2
            
            cell.timeLeftLabel.text = progress + "% \n \(countdown.0):\(countdown.1):\(countdown.2):\(countdown.3)"
        }
    }
    
    func deleteAction(sender: UISwipeGestureRecognizer) {
        var cell = sender.view as CountdownTableViewCell
        let cellIndexPath = tableView.indexPathForCell(cell)
        managedObjectContext?.deleteObject(fetchedResultsController.objectAtIndexPath(cellIndexPath!) as Countdown)
        CoredownModel.saveContext(managedObjectContext!)
    }
    
    func countingDownToCountdown(endingDate: NSDate) -> String {
        var converter = NSDateFormatter()
        converter.dateStyle = .MediumStyle
        var countdownDate = converter.stringFromDate(endingDate)
        if countdownDate.utf16Count > 0 {
            return countdownDate
        } else {
            return ""
        }
    }
    
    func displayingTheEvent(eventString: NSString) -> NSString {
        var event = NSString()
        event = "\(eventString)"
        return event
    }
    
    func countdownIsFinished(fireDate: NSDate) -> Bool {
        var now = NSDate()
        if now.earlierDate(fireDate).isEqualToDate(fireDate) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: FetchedResultsController
    
    func countdownDataAtIndexPath(indexPath: NSIndexPath) -> (notification: UILocalNotification!, eventName: String!, dateCreated: NSDate?) {
        var countdown = fetchedResultsController.objectAtIndexPath(indexPath) as Countdown
        var notification = countdown.notification as UILocalNotification
        var eventName = countdown.countdownName
        var creationDate = countdown.dateCreated
        return (notification, eventName, creationDate)
    }
    
    // MARK: <NSFetchedResultsControllerDelegate>
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        var fetchRequest = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext: managedObjectContext!)
        fetchRequest.entity = entity
        var sort = NSSortDescriptor(key: "dateCreated", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        var theFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        _fetchedResultsController = theFetchedResultsController
        _fetchedResultsController!.delegate = self
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Update to handle the error appropriately
            println("Unresolved error \(error), \(error?.userInfo)")
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        //collectionView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        // collectionView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case NSFetchedResultsChangeType.Delete:
            tableView!.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case NSFetchedResultsChangeType.Update:
            break
        case NSFetchedResultsChangeType.Move:
            tableView!.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeSection sectionInfo: NSFetchedResultsSectionInfo!, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView!.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case NSFetchedResultsChangeType.Delete:
            tableView!.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            return
        }
    }
}
