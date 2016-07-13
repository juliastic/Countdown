//
//  AddViewController.swift
//  Count Down
//
//  Created by Julia Grill on 27/02/2015.
//  Copyright (c) 2015 Julia Grill. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var countdownDate: UIDatePicker!
    @IBOutlet weak var countdownName: UITextView!
    @IBOutlet weak var componentView: UIView!
    
    let managedObjectContext = CoreDataStore.SharedInstance.managedObjectContext
    var countdownModel: CountDownModelProtocol?
    var contentVC: ContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "New Countdown"
        
        countdownDate.minimumDate = Date().addingTimeInterval(120)
        countdownName.delegate = self
        countdownName.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let blurEffect = UIBlurEffect(style: .dark)
        let bluredeffectView = UIVisualEffectView(effect: blurEffect)
        bluredeffectView.frame = view.bounds
        view.insertSubview(bluredeffectView, belowSubview: componentView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom Functions
    
    func saveCountdown() {
        let dateCreated = Date()
        if countdownName.text.characters.count > 0 {
            let countdownNotification = UILocalNotification()
            countdownNotification.fireDate = countdownDate.date
            countdownNotification.alertBody = "Your countdown \(countdownName.text!) is finished!"
            countdownNotification.applicationIconBadgeNumber = 0
            countdownNotification.timeZone = TimeZone.default()
            UIApplication.shared().scheduleLocalNotification(countdownNotification)
            CoredownModel.storeCountdownDataInManagedObjectContext(managedObjectContext, notification: countdownNotification, eventName: countdownName.text, dateCreated: dateCreated)
            self.dismiss(animated: true, completion: nil)
//            print(managedObjectContext)
        } else {
            let countdownOverAlert = UIAlertController(title: NSLocalizedString("No Event Name", comment: "Alert title when user doesnt enter an event name."), message: NSLocalizedString("Please add an event name.", comment: "Alert message when user doesn't enter an event name."), preferredStyle: UIAlertControllerStyle.alert)
            countdownOverAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            present(countdownOverAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        saveCountdown()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        countdownName.endEditing(true) // hides keyboard when hitting return
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
