//
//  MainViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 18/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import Hero
import Spring
import CoreLocation
import MapKit
import SwiftLocation
import PermissionScope


class MainViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let locationManager = CLLocationManager()
    
    let User = MainUser()
    let locationClass = locationHelp()
    
    let pscope = PermissionScope()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pscope.addPermission(LocationAlwaysPermission(), message: "We use this to track\r\nwhere you live :)")
        
        showLocationPermission(scope: pscope)
        
        initLocation()
        
        initProfileView()
        
        if user == nil {
            transitionSegue.segue.switchToLoginview()
            disconnectButton(Any.self)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
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
        print("user did logout")
    }
    
    @IBAction func profileButton(_ sender: Any) {
        if profileView.isHidden == false {
            profileView.isHidden = true
            
        } else {
            profileView.isHidden = false
        }
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        
        //let locationRef = ref.child("asks").child(user!.uid).child("location")
        
        //let country = locationRef.child("country")
        
        // Comparer localisation écrite avec localisation actuelle
        checkCurrentUserLocationWithAdress()
    }
    
    func initProfileView() {
        
        let userName = User.getUserName()
        
        nameLabel.text = userName
        emailLabel.text = user?.email
    }
    
    func checkCurrentUserLocationWithAdress() -> Bool {
        
        let currentLocation: CLLocation = locationClass.getLocation()
        
        let userHomeAdress = locationClass.getUserDatabaseAdress(uid: user!.uid)
        print(userHomeAdress)
        
        let homeLocation: CLLocation = locationClass.getUserHomeLocation(address: userHomeAdress)
        
        //let adressLocation: CLLocation = locationClass.getLocation()
       
        let distance = getLocationsDistance(location1: currentLocation, location2: homeLocation)
        
        print(distance)
        
        if distance < 200.00 {
            print("Less than 200m! Good!")
            return true
        } else {
            print("More than 200m! Not good!")
            return false
        }
        
    }
    
    func getLocationsDistance(location1: CLLocation, location2: CLLocation) -> Double {
        
            let distanceMeters = location1.distance(from: location2)
        
            return distanceMeters

    }
   
    func showLocationPermission(scope: PermissionScope!) {
        scope.show(
            { finished, results in
                print("got results \(results)")
        },
            cancelled: { results in
                print("thing was cancelled")
        }
        )
    }
}
