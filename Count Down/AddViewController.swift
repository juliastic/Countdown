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
        
        countdownDate.alpha = 0
        countdownName.alpha = 0
        componentView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let blurEffect = UIBlurEffect(style: .dark)
        let bluredEffectView = UIVisualEffectView(effect: blurEffect)
        bluredEffectView.frame = view.bounds
        view.insertSubview(bluredEffectView, belowSubview: componentView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 1) {
            self.countdownDate.alpha = 1
            self.countdownName.alpha = 1
            self.componentView.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom Functions
    
    private func saveCountdown() {
        if countdownName.text.count > 0 {
            let countdownNotification = UILocalNotification()
            countdownNotification.fireDate = countdownDate.date
            countdownNotification.alertBody = "Your countdown \(countdownName.text!) is finished!"
            countdownNotification.applicationIconBadgeNumber = 0
            UIApplication.shared.scheduleLocalNotification(countdownNotification)
            CoredownModel.storeCountdownDataInManagedObjectContext(managedObjectContext, notification: countdownNotification, eventName: countdownName.text, dateCreated: Date())
            dismiss(animated: false, completion: nil)
        } else {
            let countdownOverAlert = UIAlertController(title: NSLocalizedString("No Event Name", comment: "Alert title when user doesnt enter an event name."), message: NSLocalizedString("Please add an event name.", comment: "Alert message when user doesn't enter an event name."), preferredStyle: UIAlertController.Style.alert)
            countdownOverAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(countdownOverAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.5) {
            self.countdownDate.alpha = 0
            self.countdownName.alpha = 0
            self.componentView.alpha = 0
        }
        
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func saveButton(_ sender: AnyObject) {
        saveCountdown()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        countdownName.endEditing(true)
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
