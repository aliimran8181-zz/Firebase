//
//  LoginViewController.swift
//  BirthdayCalculator
//
//  Created by Ali on 04/01/2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var passwordTextFeild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func LoginBtn(_ sender: UIButton) {
        // Create cleaned versions of the text field
        let email = emailTextFeild.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextFeild.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
    
            }
            else {
                
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        
    }
    
}
}

