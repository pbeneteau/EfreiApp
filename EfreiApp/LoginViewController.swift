//
//  LoginViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 18/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: keyboardUtils {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var telField: UITextField!
    @IBOutlet weak var adressField: UITextField!
    
    @IBOutlet weak var loginEmailField: UITextField!
    
    @IBOutlet weak var loginPasswordField: UITextField!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signInView: UIView!
    
    @IBOutlet weak var selectionBar: UIView!
    
    let ref = FIRDatabase.database().reference() // Firebase database ref
    let user = FIRAuth.auth()?.currentUser // User ref
    
    let keyboardClass = keyboardUtils!.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ( user != nil) {
            // if user already logged in...
            transitionSegue.segue.switchToNavigationController()
        }
        
        loginView.frame.origin.x = 39
        signInView.frame.origin.x = 39 - 400
                
        setPredictiveState(state: .no)
        
        addObservers()
        
        // delegates for textFields
        setDelegates(nameField, emailField, passwordField, loginEmailField,  loginPasswordField, telField, adressField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Signin
    @IBAction func signInButtonAction(_ sender: Any) {
        dismissKeyboard()
        
        if ((emailField.text == "") || (passwordField.text == "") || (nameField.text == "") || (telField.text == "") || (adressField.text == "")) {
            let alertController = UIAlertController(title: "Erreur", message: "Please enter all informations needed", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                
                if error == nil {
                    
                    self.ref.child("users").child(user!.uid).child("name").setValue(self.nameField.text)
                    self.ref.child("users").child(user!.uid).child("email").setValue(self.emailField.text)
                    self.ref.child("users").child(user!.uid).child("tel").setValue(self.telField.text)
                    self.ref.child("users").child(user!.uid).child("address").setValue(self.adressField.text)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Login
    @IBAction func loginButton(_ sender: Any) {
        dismissKeyboard()
        
        if self.loginEmailField.text == "" || self.loginPasswordField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter your password and email", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.loginEmailField.text!, password: self.loginPasswordField.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        
        
        if self.loginEmailField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.sendPasswordReset(withEmail: self.loginEmailField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Succès!"
                    message = "A mail have been sent"
                    self.loginEmailField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
    
    
    @IBAction func showLoginView(_ sender: Any) {
        
        if loginView.frame.origin.x == 439.0 {
            
            animation(actual: "login")
        }
    }
    
    @IBAction func showSigninView(_ sender: Any) {
       
        if signInView.frame.origin.x == -361.0 {
            
            animation(actual: "signin")
        }
    }
    
    func setPredictiveState(state: UITextAutocorrectionType) {
        
        nameField.autocorrectionType = state
        emailField.autocorrectionType = state
        passwordField.autocorrectionType = state
        adressField.autocorrectionType = state
        telField.autocorrectionType = state
        
        loginPasswordField.autocorrectionType = state
        loginEmailField.autocorrectionType = state
    }
    
    func animation(actual: String) {
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            
            if actual == "login" {
            
                self.selectionBar.frame.origin.x -= 185.5
                if self.signInView.frame.origin.x != -439 {
                    self.signInView.frame.origin.x -= 400.0
                }
                self.loginView.frame.origin.x -= 400.0
                
            } else {
                
                self.selectionBar.frame.origin.x += 185.5
                self.signInView.frame.origin.x += 400.0
                self.loginView.frame.origin.x += 400.0
            }
            
            
        })
        
    }
    
}





