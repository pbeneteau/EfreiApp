//
//  MainViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 18/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import  Hero

class MainViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserName()
        emailLabel.text = user?.email
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        transitionSegue.segue.switchToLoginview()
        print("user did logout")
    }
    
    func getUserName() {
        let userRef = ref.child("users").child(user!.uid).child("name")
        
        userRef.observe(FIRDataEventType.value, with: { (snapshot) in
            let name = snapshot.value as? String
            self.nameLabel.text = name
        })
    }
  
    @IBAction func profileButton(_ sender: Any) {
        if profileView.isHidden == false {
             profileView.isHidden = true
            profileView.heroModifiers = [.translate(x:0, y:100), .scale(0.5)]
        } else {
            profileView.isHidden = false
        }
    }
   
    
}
