//
//  RegistrationViewController.swift
//  GroupUP
//
//  Created by Tony De La Nuez on 4/5/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

class RegistrationViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func createAccount(_ sender: UIButton) {
        if emailTextField.text == "" {
            //Prompt user for input if empty username
            let alertController = UIAlertController(title: "Error", message: "Please enter a valid email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated:true, completion: nil)
            
        }
        
        else if passwordTextField.text == "" {
            //Prompt user for input if empty password
            let alertController = UIAlertController(title: "Error", message: "Please enter a password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated:true, completion: nil)
        } else {
            //Call for firebase authentication
            FIRAuth.auth()?.createUser(withEmail:emailTextField.text!, password:passwordTextField.text!) { (user, error) in
            
            //Check if success
            if error == nil {
                print("Registration Complete!")
                let alertController = UIAlertController(title: "Account Created.", message: "Registration Complete!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated:true, completion: nil)
                
                //Take user to map if they've logged in.
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                self.present(vc!, animated: true, completion: nil )
            } else {
                //Registration failed. Alert. 
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated:true, completion: nil)
            
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
