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
    
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signinView: UIView!

    
    let ref = FIRDatabase.database().reference() // Firebase database ref
    let user = FIRAuth.auth()?.currentUser // User ref
    
    let keyboardClass = keyboardUtils!.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        
        if ( user != nil) {
            // if user already logged in...
            transitionSegue.segue.switchToNavigationController()
        }
        
        // delegates for textFields
        setDelegates(nameField, emailField, passwordField, loginEmailField,  loginPasswordField)
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
    @IBAction func signInButton(_ sender: Any) {
        dismissKeyboard()
        
        if ((emailField.text == "") || (passwordField.text == "") || (nameField.text == "")) {
            let alertController = UIAlertController(title: "Erreur", message: "Veuillez saisir votre mot de passe et adresse email", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                
                if error == nil {
                    
                    self.ref.child("users").child(user!.uid).child("name").setValue(self.nameField.text)
                    self.ref.child("users").child(user!.uid).child("email").setValue(self.emailField.text)
                    
                            
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Erreur", message: error?.localizedDescription, preferredStyle: .alert)
                    
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
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
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
    
        passwordField.isHidden = true
        
        if self.emailField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Entrez un email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.sendPasswordReset(withEmail: self.emailField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Erreur!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Succès!"
                    message = "Un mail vous a été envoyé"
                    self.emailField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
        passwordField.isHidden = false
    }
    
    @IBAction func showLoginview(_ sender: Any) {
        loginView.isHidden = false
        signinView.isHidden = true
    }
    @IBAction func showSigninView(_ sender: Any) {
        loginView.isHidden = true
        signinView.isHidden = false
    }

}





