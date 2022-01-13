//
//  SignupViewController.swift
//
//  Created by Ali on 04/01/2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class SignupViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//IBOutlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    //variables
    var ref: DatabaseReference!
    private let storage = Storage.storage().reference()
    
    var imageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            dobTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    
    @IBAction func SignupBtn(_ sender: UIButton) {
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let dob = dobTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            
            // Check for errors
            if err != nil {
                self.displayMyAlertMessage(userMessage: "")
                // There was an error creating the user
            }
            else {
                
                // User was created successfully, now store the first name and last name
                self.ref = Database.database().reference()
                self.ref.child("users").child(result!.user.uid).setValue(["firstname": firstName, "lastname": lastName, "dob": dob,"pic":self.imageUrl])
                self.transitionToHome()
            }
            
        }
    }
    
    @IBAction func uploadBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imgView.image = image
        picker.dismiss(animated: true, completion: nil)

        
        guard let imagedata = image.pngData() else{
            return
        }
        
    
        storage.child("images/file.png").putData(imagedata, metadata: nil, completion: {_, error in
                guard error == nil else{
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/file.png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else{
                    return
                }
                let urlString = url.absoluteString
                print(urlString)
                
                guard let imgUrl = URL(string: urlString) else {
                          return
                }
                
                //TODO" assign url to image url
                self.imageUrl = urlString
                
                let task = URLSession.shared.dataTask(with: imgUrl, completionHandler: {data, _, error in
                        guard let data = data, error == nil else{
                        return
                    }
                    DispatchQueue.main.sync(){
                    let image = UIImage(data: data)
                        self.imgView.image = image
                        
                    }
                })
                task.resume()

            })
        }
        )
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func transitionToHome() {
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    func displayMyAlertMessage(userMessage:String){
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            
            
        })
        myAlert.addAction(okAction)
        self.present(myAlert,animated: true,completion: nil)
    }
    
}
