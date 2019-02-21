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
    
    var managedObjectContext = CoreDataStore.SharedInstance.managedObjectContext
    var countdownModel: CountDownModelProtocol?
    var pageViewController: UIPageViewController?

    var updateLabelsTimer = Timer()
    var pageCountdown: Date!
    var pageString = ""
    var currentIndex = 0
    var popOverBool = true
    
    var countdownDate: Date? {
        didSet {
            updateLabelsTimer.invalidate()
            updateLabelsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimeRemaining), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
        let fetchRequestData: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")

        let entity = NSEntityDescription.entity(forEntityName: "Countdown", in:managedObjectContext)
        fetchRequestData.entity = entity
        
        let defaults = UserDefaults.standard
        let newDataAdded = defaults.bool(forKey: "newDataAdded")
        let countdownForKey = defaults.integer(forKey: "indexClicked")
        
        if newDataAdded {
            do {
                let fetchedObjects = try managedObjectContext.fetch(fetchRequestData) as! [Countdown]
                let fetchedObject = fetchedObjects[countdownForKey]
                countdownDate = fetchedObject.notification.fireDate
                eventDescriptionLabel.text = fetchedObject.countdownName
                defaults.set(false, forKey: "newDataAdded")
            } catch let error as NSError {
                let alert = UIAlertController(title: "Error", message: "Items couldn't be fetched", preferredStyle: .alert)
                present(alert, animated: true, completion: nil)
                print("Fetch failed: \(error.localizedDescription)")
            }
            
        } else {
            countdownDate = pageCountdown
            eventDescriptionLabel.text = pageString
        }
        
        updateTimeRemaining()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Custom Functions
    
    func numberOfCountdowns() -> Int {
        let fetchRequestData: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        let entity = NSEntityDescription.entity(forEntityName: "Countdown", in:managedObjectContext)
        fetchRequestData.entity = entity
        
        let dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequestData.sortDescriptors = [dateSort]
        fetchRequestData.fetchLimit = 20
        
        let countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        fetchRequestData.sortDescriptors = [countdownNameSort]
        fetchRequestData.fetchLimit = 20
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequestData) as! [Countdown]
            return fetchedObjects.count
        } catch let error as NSError {
            print(error)
            return 0
        }
    }
    
    @objc func updateTimeRemaining() {
        let (days, hours, minutes, seconds) = TimeFormatter.calculateTime(Date(), fireDate: countdownDate!)
        daysLabel.text = "\(days)"
        hoursLabel.text = "\(hours)"
        minutesLabel.text = "\(minutes)"
        secondsLabel.text = "\(seconds)"
        
        if countdownDate?.compare(Date()) == ComparisonResult.orderedAscending && popOverBool == true {
            let countdownOverAlert = UIAlertController(title: "Countdown over!", message: "This countdown is finished!", preferredStyle: UIAlertController.Style.alert)
            countdownOverAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            view.window?.rootViewController?.present(countdownOverAlert, animated: true, completion: nil)
            popOverBool = false
        }
    }
}

