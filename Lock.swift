//
//  Lock.swift
//  CampusNoteTest
//
//  Created by user on 2017. 11. 24..
//  Copyright © 2017년 user. All rights reserved.
//

import UIKit
import LocalAuthentication

class Lock: UIViewController {
  
        @IBOutlet weak var authentication: UILabel!
        @IBOutlet weak var resultLabel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            resultLabel?.text = ""
        }
        
        
        @IBAction func authenticationAction(_ sender: Any) {
            
            let alertController = UIAlertController(title: "Authentication",message: "Please choose Touch ID or Passcode", preferredStyle: .actionSheet)
            
            let touchidAction = UIAlertAction(title: "Touch ID", style: .default,handler: {action in self.touchid_func()})
            
            let passcodeAction = UIAlertAction(title: "Password", style: .default, handler: {action in self.passcode_func()})
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(touchidAction)
            alertController.addAction(passcodeAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        
        func touchid_func() {
            
            let context = LAContext()
            var error : NSError?
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "User Authentication (Press Button)", reply:
                    {success, error in
                        if success {
                            self.resultLabel.text = "SUCCESS"
                        } else {
                            self.resultLabel.text = "FAILED"
                        }
                })
            } else {
                resultLabel.text = "No Touch ID in the device"
                
            }
        }
        
        func passcode_func() {
            
            var loginid: UITextField?
            var pass: UITextField?
            
            let alertController = UIAlertController(title: "Authentication Test", message: "Please enter your password", preferredStyle: .alert)
            
            let loginAction = UIAlertAction(title: "Login", style: .default, handler: {action in self.compare_func(loginid: loginid!.text!, pass: pass!.text!)})
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(loginAction)
            
            alertController.addTextField(configurationHandler: {(textField:UITextField!) -> Void in
                
                loginid = textField
                textField.placeholder = "ID"
            })
            
            alertController.addTextField(configurationHandler: {(textField:UITextField!) -> Void in
                
                pass = textField
                textField.placeholder = "Your password"
                textField.isSecureTextEntry = true
                
            })
            
            present(alertController, animated: true, completion: nil)
        }
        
        func compare_func(loginid: String, pass: String) {
            
            print(loginid, pass)
            
            let correct_loginid = "team"
            let correct_passwd = "apple"
            
            if(loginid == correct_loginid && pass == correct_passwd) {
                
                resultLabel.text = "SUCCESS"
            } else {
                
                resultLabel.text = "FAILED"
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}

