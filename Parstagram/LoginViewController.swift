//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Meagan Olsen on 11/15/19.
//  Copyright © 2019 Meagan Olsen. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   // MARK: private methods
    private func showErrorAlert(with title: String,message:String ){
       let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        guard let username = usernameField.text,
            let password = passwordField.text else{
                return
        }
        if username.isEmpty || password.isEmpty{
            let errorTitle = "Cannot Sign In"
            let pass = "Please fill out all fields"
            showErrorAlert( with:errorTitle , message: pass)
        }
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else{
                print("Error:\(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        guard let username = usernameField.text,
                  let password = passwordField.text else{
                      return
              }
        if username.isEmpty || password.isEmpty{
            let errorTitle = "Cannot Sign Up"
            let pass = "Please fill out all fields"
            showErrorAlert( with:errorTitle , message: pass)
        }
        let user = PFUser()
        user.username = username
        user.password = password
        
        user.signUpInBackground { (success, error) in
            if (success){
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Error:\(error?.localizedDescription)")
            }
        }
        
        
    }
}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


