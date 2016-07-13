//
//  OverViewViewController.swift
//  Count Down
//
//  Created by Julia Grill on 31/05/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import UIKit
import CoreData

class OverViewViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    let managedObjectContext = CoreDataStore.SharedInstance.managedObjectContext
    let defaults = UserDefaults.standard()
    let calculationStruct = CalculationStruct()
    
    var editingBool = true
    var updateCellContentsTimer: Timer?
    var lastAddedCellColor: UIColor?
    var recentlyTappedCellColor: UIColor?

    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editingBool, animated: animated)
        tableView.setEditing(editingBool, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        emptyStateLabel.isHidden = fetchedResultsController.fetchedObjects?.count != 0

        tableView.isScrollEnabled = fetchedResultsController.fetchedObjects?.count != 0
        tableView.delegate = self
        tableView.dataSource = self
        
        addButton.layer.borderWidth = 2.0
        addButton.layer.borderColor = UIColor.black().cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateCellContentsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: "updateCells", userInfo: nil, repeats: true)
        updateCells()
    }
    
    // MARK: Custom Functions
    
    func updateCells() {
        let indexPathsArray = tableView.indexPathsForVisibleRows
        for indexPath in indexPathsArray! {
            let cell = tableView.cellForRow(at: indexPath) as! CountdownTableViewCell
            //remove second argument when I'm less lazy
            let (notification, _, dateCreated) = countdownDataAtIndexPath(indexPath)
            let now = Date()
            let progress = CalculationStruct.calculateProgress(dateCreated!, fireDate: notification!.fireDate!)
            let countdown = TimeFormatter.calculateTime(now, fireDate: notification!.fireDate!)
            
            cell.timeLeftLabel.text = progress + "\t \(countdown.0):\(countdown.1):\(countdown.2):\(countdown.3)"
        }
    }
    
    func countdownDataAtIndexPath(_ indexPath: IndexPath) -> (notification: UILocalNotification?, eventName: String?, dateCreated: Date?) {
        let countdown = fetchedResultsController.object(at: indexPath) as? Countdown
        let notification = countdown?.notification as? UILocalNotification
        let eventName = countdown?.countdownName
        let creationDate = countdown?.dateCreated
        return (notification, eventName, creationDate)
    }
    
     // MARK: - Table View data source
    
    func tableView(_ tableView: UITableView, numberOfRowsDidChange rows: Int, inSection section: Int) {
        emptyStateLabel.isHidden = rows != 0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionsArray = fetchedResultsController.sections {
            let numberOfObjectsInSections = sectionsArray[section].numberOfObjects
            return numberOfObjectsInSections
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CountdownTableViewCell
        let (notification, eventName, dateCreated) = countdownDataAtIndexPath(indexPath)
        let now = Date()
        
        let differentColors = [UIColor(red: 50.0, green: 60.0, blue: 60.0, alpha: 1), UIColor.blue(), UIColor.red(), UIColor.lightGray(), UIColor.green()]
        let randomIndex = Int(arc4random_uniform(UInt32(differentColors.count)))
        let randomBackgroundColor = differentColors[randomIndex]
        let lastAddedIndex = randomIndex
        
        var color: UIColor
        
        if lastAddedCellColor == randomBackgroundColor {
            if lastAddedIndex < differentColors.count+1 {
                color = differentColors[lastAddedIndex]
                cell.countdownName.backgroundColor = color
            } else {
                color = differentColors[lastAddedIndex-1]
                cell.countdownName.backgroundColor = color
            }
        } else {
            cell.countdownName.backgroundColor = randomBackgroundColor
            color = randomBackgroundColor
        }
        
        let progress = CalculationStruct.calculateProgress(dateCreated!, fireDate: (notification?.fireDate!)!)
        let countdown = TimeFormatter.calculateTime(now, fireDate: notification!.fireDate!)
        cell.countdownName.text = eventName! + "\t" + CalculationStruct.countingDownToCountdown(notification!.fireDate!)!
        cell.timeLeftLabel.text = progress + "\t \(countdown.0):\(countdown.1):\(countdown.2):\(countdown.3)"
        
        lastAddedCellColor = color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set((indexPath as NSIndexPath).row, forKey: "indexClicked")

        recentlyTappedCellColor = tableView.cellForRow(at: indexPath)!.contentView.backgroundColor
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.lightGray()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = recentlyTappedCellColor
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            managedObjectContext.delete(fetchedResultsController.object(at: indexPath) as! Countdown)
            CoredownModel.saveContext(managedObjectContext)
        }
    }

    // MARK: <NSFetchedResultsControllerDelegate>
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        let entity = NSEntityDescription.entity(forEntityName: "Countdown", in: managedObjectContext)
        fetchRequest.entity = entity
        let sort = SortDescriptor(key: "dateCreated", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        
        let theFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        _fetchedResultsController = theFetchedResultsController
        _fetchedResultsController!.delegate = self
        
        var error: NSError? = nil
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error?.userInfo)")
        }

        
        if error != nil {
            print("Unresolved error \(error), \(error?.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        tableView.isScrollEnabled = fetchedResultsController.fetchedObjects?.count != 0
        emptyStateLabel.isHidden = fetchedResultsController.fetchedObjects?.count != 0
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.delete:
            tableView!.deleteRows(at: [indexPath!], with: .automatic)
        case NSFetchedResultsChangeType.update:
            break
        case NSFetchedResultsChangeType.move:
            tableView!.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            tableView!.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case NSFetchedResultsChangeType.delete:
            tableView!.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "viewVC" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationVC = navigationController.topViewController as! ContentViewController
            destinationVC.countdownArray = fetchedResultsController.fetchedObjects as! [Countdown]
        }
    }
}
