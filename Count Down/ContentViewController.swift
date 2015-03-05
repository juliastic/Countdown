//
//  ContentViewController.swift
//  Count Down
//
//  Created by Julia Grill on 27/02/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import UIKit
import CoreData

class ContentViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var managedObjectContext: NSManagedObjectContext?
    var currentIndex = 0
    var amountOfCountdowns = 1
    var placeholderViewController: UIViewController!
    var pageViewController: UIPageViewController!
    var countdownArray = []
    
    var presentationIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageControl()
        reset()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
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
    }
    
    override func viewWillAppear(animated: Bool) {
        reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    func reset() {
        let numCountdowns = getCountdowns().count
        countdownArray = getCountdowns()
        if numCountdowns > 0 && pageViewController?.parentViewController == nil {
            pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as UIPageViewController
            pageViewController.dataSource = self
            placeholderViewController?.willMoveToParentViewController(nil)
            pageViewController.willMoveToParentViewController(self)
            pageViewController?.removeFromParentViewController()
            addChildViewController(pageViewController)
            view.addSubview(pageViewController.view)
            placeholderViewController?.didMoveToParentViewController(nil)
            pageViewController.didMoveToParentViewController(self)
            
            var viewController: ViewController?
            var countdownForKey = NSUserDefaults.standardUserDefaults().integerForKey("indexClicked")
            
            if countdownForKey != NSNotFound {
                viewController = countdownAtIndex(countdownForKey)
                println(viewController)
            } else {
                viewController = countdownAtIndex(0)
            }
            pageViewController.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        } else if numCountdowns <= 0 && placeholderViewController?.parentViewController == nil {
            placeholderViewController = storyboard?.instantiateViewControllerWithIdentifier("placeHolderView") as UIViewController
            pageViewController?.willMoveToParentViewController(nil)
            placeholderViewController.willMoveToParentViewController(self)
            pageViewController?.removeFromParentViewController()
            addChildViewController(placeholderViewController)
            view.addSubview(placeholderViewController.view)
            pageViewController?.didMoveToParentViewController(nil)
            placeholderViewController.didMoveToParentViewController(self)
        }
    }
    
    func getCountdowns() -> Array<Countdown> {
        var fetchRequestData = NSFetchRequest()
        var error: NSError? = nil
        
        var entity = NSEntityDescription.entityForName("Countdown", inManagedObjectContext:managedObjectContext!)
        
        fetchRequestData.entity = entity
        var dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        var countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        
        var fetchedObjects = (managedObjectContext!.executeFetchRequest(fetchRequestData, error:&error) as [Countdown])
        return fetchedObjects
    }
    
    //TODO: problem with index
    
    func countdownAtIndex(index: Int) -> ViewController {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("detailVC") as ViewController
        
        amountOfCountdowns = countdownArray.count
        if countdownArray.count > 0 {
            if index >= countdownArray.count {
                reset()
            } else {
                let selectedCountdown: Countdown = countdownArray[index] as Countdown
                let fireDate = selectedCountdown.notification.fireDate
                viewController.pageString = selectedCountdown.countdownName
                viewController.pageCountdown = fireDate
            }
            viewController.managedObjectContext = managedObjectContext
            currentIndex = index
        } else {
            viewController.pageString = ""
            viewController.pageCountdown = nil
            reset()
        }
        return viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if currentIndex > 0 || currentIndex < countdownArray.count {
            return countdownAtIndex(currentIndex+1)
        } else {
            return countdownAtIndex(0)
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if currentIndex > 0 || currentIndex < getCountdowns().count {
            return countdownAtIndex(currentIndex-1)
        } else {
            return countdownAtIndex(countdownArray.count)
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return countdownArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        var countdownForKey = NSUserDefaults.standardUserDefaults().integerForKey("indexClicked")
        
        if countdownForKey != NSNotFound {
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "indexClicked")
            return countdownForKey
        } else {
            return 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCountdown" {
            let navigationController = segue.destinationViewController as UINavigationController
            let destinationVC = navigationController.topViewController as AddViewController
            destinationVC.managedObjectContext = managedObjectContext
        } else if segue.identifier == "showCountdowns" {
            let contentViewController = segue.destinationViewController as CountdownTableViewController
            contentViewController.managedObjectContext = managedObjectContext!
        }
    }
}
