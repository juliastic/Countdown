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

    let managedObjectContext = CoreDataStore.SharedInstance.managedObjectContext
    let defaults = UserDefaults.standard()

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Custom Functions
    
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray()
        appearance.currentPageIndicatorTintColor = UIColor.white()
        appearance.backgroundColor = UIColor.darkGray()
    }
    
    func reset() {
        countdownArray = getCountdowns()
        let numCountdowns = countdownArray.count
        
        if numCountdowns > 0 && pageViewController?.parent == nil {
            pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
            pageViewController.dataSource = self
            placeholderViewController?.willMove(toParentViewController: nil)
            pageViewController.willMove(toParentViewController: self)
            pageViewController?.removeFromParentViewController()
            addChildViewController(pageViewController)
            view.addSubview(pageViewController.view)
            placeholderViewController?.didMove(toParentViewController: nil)
            pageViewController.didMove(toParentViewController: self)
            
            let viewController: ViewController
            let countdownForKey = UserDefaults.standard().integer(forKey: "indexClicked")
            
            if countdownForKey != NSNotFound {
                viewController = countdownAtIndex(countdownForKey)
            } else {
                viewController = countdownAtIndex(0)
            }
            
            pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            
            pageViewController.view.isUserInteractionEnabled = getCountdowns().count != 1
        } else if numCountdowns <= 0 && placeholderViewController?.parent == nil {
            placeholderViewController = storyboard!.instantiateViewController(withIdentifier: "placeHolderView") 
            pageViewController?.willMove(toParentViewController: nil)
            placeholderViewController.willMove(toParentViewController: self)
            pageViewController?.removeFromParentViewController()
            addChildViewController(placeholderViewController)
            view.addSubview(placeholderViewController.view)
            pageViewController?.didMove(toParentViewController: nil)
            placeholderViewController.didMove(toParentViewController: self)
        }
    }
    
    func getCountdowns() -> [Countdown] {
//            let fetchRequestData = Countdown.fetchRequest()
        let fetchRequestData: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        let entity = NSEntityDescription.entity(forEntityName: "Countdown", in: managedObjectContext)
        fetchRequestData.entity = entity
        let dateSort = SortDescriptor(key: "dateCreated", ascending: false)
        let countdownNameSort = SortDescriptor(key: "countdownName", ascending: false)
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        
//        guard fetchRequestData.accessibilityElementCount() != 0 else { throw Error.FetchingError }
        
        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequestData) as! [Countdown]
            return fetchedObjects
//        } catch Error.FetchingError {
//            print("Error whilst fetching countdowns")
//            return []
        } catch let error as NSError {
            print("Error whilst getting countdowns: \(error)")
            return []
        }
    }
    
    func countdownAtIndex(_ index: Int) -> ViewController {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! ViewController
        amountOfCountdowns = countdownArray.count
        
        if countdownArray.count > 0 {
            if index >= countdownArray.count {
                reset()
            } else {
                let selectedCountdown = countdownArray[index] as! Countdown
                let fireDate = selectedCountdown.notification.fireDate!
                viewController.pageString = selectedCountdown.countdownName
                viewController.pageCountdown = fireDate
            }
            viewController.managedObjectContext = managedObjectContext
            currentIndex = index
        } else {
            viewController.pageString = "No Countdowns"
            viewController.pageCountdown = nil
            reset()
        }
        return viewController
    }
    
    // MARK: UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex > 0 && currentIndex < countdownArray.count {
            return countdownAtIndex(currentIndex+1)
        } else {
            return countdownAtIndex(0)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex > 0 && currentIndex < countdownArray.count {
            return countdownAtIndex(currentIndex-1)
        } else {
            return countdownAtIndex(0)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return countdownArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let countdownForKey = defaults.integer(forKey: "indexClicked")
        if countdownForKey != NSNotFound {
            UserDefaults.standard().set(0, forKey: "indexClicked")
            return countdownForKey
        } else {
            return 1
        }
    }
    
    enum Error: ErrorProtocol {
        case FetchingError
    }
}
