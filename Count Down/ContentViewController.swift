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

    private let managedObjectContext = CoreDataStore.SharedInstance.managedObjectContext
    private let defaults = UserDefaults.standard

    private var currentIndex = 0
    private var placeholderViewController: UIViewController!
    private var pageViewController: UIPageViewController!
    private var presentationIndex: Int?
    
    var countdownArray = Array<AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageControl()
        reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Custom Functions
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    private func reset() {
        countdownArray = getCountdowns()
        let numCountdowns = countdownArray.count
        
        if numCountdowns > 0 && pageViewController?.parent == nil {
            pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
            pageViewController.dataSource = self
            placeholderViewController?.willMove(toParent: nil)
            pageViewController.willMove(toParent: self)
            pageViewController?.removeFromParent()
            addChild(pageViewController)
            view.addSubview(pageViewController.view)
            placeholderViewController?.didMove(toParent: nil)
            pageViewController.didMove(toParent: self)
            
            let viewController: MainViewController
            let countdownForKey = UserDefaults.standard.integer(forKey: "indexClicked")
            viewController = countdown(at: countdownForKey)
            
            pageViewController.setViewControllers([viewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
            
            pageViewController.view.isUserInteractionEnabled = getCountdowns().count != 1
        } else if numCountdowns <= 0 && placeholderViewController?.parent == nil {
            placeholderViewController = storyboard!.instantiateViewController(withIdentifier: "placeHolderView") 
            pageViewController?.willMove(toParent: nil)
            placeholderViewController.willMove(toParent: self)
            pageViewController?.removeFromParent()
            addChild(placeholderViewController)
            view.addSubview(placeholderViewController.view)
            pageViewController?.didMove(toParent: nil)
            placeholderViewController.didMove(toParent: self)
        }
    }
    
    private func getCountdowns() -> [Countdown] {
        let fetchRequestData: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        let entity = NSEntityDescription.entity(forEntityName: "Countdown", in: managedObjectContext)
        fetchRequestData.entity = entity
        let dateSort = NSSortDescriptor(key: "dateCreated", ascending: false)
        let countdownNameSort = NSSortDescriptor(key: "countdownName", ascending: false)
        
        fetchRequestData.sortDescriptors = [dateSort, countdownNameSort]
        
        do {
            let fetchedObjects = try managedObjectContext.fetch(fetchRequestData) as! [Countdown]
            return fetchedObjects
        } catch let error as NSError {
            print("Error whilst getting countdowns: \(error)")
            return []
        }
    }
    
    private func countdown(at index: Int) -> MainViewController {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! MainViewController
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
        if currentIndex < countdownArray.count {
            return countdown(at: currentIndex+1)
        } else {
            return countdown(at: 0)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex > 0 && currentIndex < countdownArray.count {
            return countdown(at: currentIndex-1)
        } else if currentIndex == 0 {
            return countdown(at: countdownArray.count-1)
        } else {
            return countdown(at: 0)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return countdownArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let countdownForKey = defaults.integer(forKey: "indexClicked")
        if countdownForKey != NSNotFound {
            UserDefaults.standard.set(0, forKey: "indexClicked")
            return countdownForKey
        }
        return 0
    }
}
