//
//  ViewController.swift
//  TouchID-DemoApp
//
//  Created by Brian Lim on 1/13/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        authenticateUser()
    }
    
    // This method will be responsible for initiating and handling Touch ID authentication.
    func authenticateUser() {
        let context: LAContext = LAContext()
        var error: NSError?
        // Apple recommends that you display a quick explanation of why you are trying to authenticate the user using Touch ID.
        let myLocalizedReasonString: NSString = "Authentication is required"
        
        // Check if the device is actually compatible with Touch ID. Ask the current authentication context if the policy can be evaluated
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Now evaluate the policy & set up the success or failure options
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString as String, reply: { (success: Bool, evaluationError: NSError?) -> Void in
                // If success is true, then do the following
                if success {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        print("TouchID Authenticated, TouchID Dismissed")
                        self.loadData()
                    })
                    // If success is not true, handle the errors
                } else {
                    // Authentification Failed
                    print(evaluationError?.localizedDescription)
                    
                    // Different cases of errors or failures
                    switch evaluationError!.code {
                    case LAError.SystemCancel.rawValue:
                        print("Authentication cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        print("Authentication cancelled by the user")
                    case LAError.UserFallback.rawValue:
                        print("User wants to use a password")
                        // We show the alert view in the main thread (Always update the UI in the main thread)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        print("Authentication Failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
                
            })
            // The device is not compatible with TouchID (Meaning, there is no fingerprint recognition on the phone)
        } else {
            switch error!.code {
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                print("Passcode not set")
            default:
                print("TouchID not available")
            }
            self.showPasswordAlert()
        }
    }
    
    // This function is called when authentication is successful
    func loadData() {
        // Do whatever you want
        print("Load Data")
    }
    
    func showPasswordAlert() {
        // Creating a alert controller
        let alertController: UIAlertController = UIAlertController(title: "TouchID Demo", message: "Please enter password", preferredStyle: UIAlertControllerStyle.Alert)
        // We define the actions to add to the alert controller
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print(action)
        }
        let doneAction: UIAlertAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) { (action) -> Void in
            let passwordTextField = alertController.textFields![0] as UITextField
            self.login(passwordTextField.text!)
        }
        // Setting the done action to disable for the condition below
        doneAction.enabled = false
        
        // We are customizing the text field using a configuration handler
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            // secureTextEntry turns the users input into dots
            textField.secureTextEntry = true
            
            // A notification that fires when the user changes the text inside the field, so you can update the done button.
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                // If there is text in the textField, then set enable the done action
                doneAction.enabled = textField.text != ""
            })
        }
        
        // Adding the actions that were created to the alert view
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        // Presenting the alert controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func login(password: String) {
        // Checking if the password that is passed in is equal to the one that the user sets
        if password == "theskyisblue" {
            // If so, call the load Data function
            self.loadData()
        } else {
            // If not, show the alert view again
            self.showPasswordAlert()
        }
    }


}

