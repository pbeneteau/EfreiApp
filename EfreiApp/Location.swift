//
//  Location.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 11/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation
import MapKit
import FirebaseDatabase
import SwiftyJSON
import Firebase

class locationHelp {
    
    let Location1:LocationManager = LocationManager()
    
    let ref = FIRDatabase.database().reference()
    
    
    private var userHomeLocation: CLLocation!
    private var location: CLLocation!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var address: String!
    
    func setLocation(location: CLLocation) {
        getAdressFromCoordinates(location: location)
    }
    
    func getUserLocation() {
        _ = LocationManager().getLocation(withAccuracy: .block, frequency: .oneShot, timeout: 50, onSuccess: { (location) in
            self.location = location
        }) { (lastValidLocation, error) in
            print("location fail")
        }
    }
    
    // Get user City, PostalCode and Country code
    func getAdressFromCoordinates(location: CLLocation) {
        _ = Location1.reverse(coordinates: location.coordinate, onSuccess: { foundPlacemark in
            self.city = foundPlacemark.locality
            self.countryCode = foundPlacemark.isoCountryCode
            self.postalCode = foundPlacemark.postalCode
        }) { error in
            print("Error: \(error)")
        }
    }
    
    // Get user coordinates from adress
    func coordinatesFromAdress(address: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            self.userHomeLocation = placemark?.location
        }
    }
    
    func retrieveUserDatabaseAdress(userID: String) {
        
        let userRef = ref.child("users").child(userID)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        userRef.observeSingleEvent(of: .value, with:  { (snapshot) in
            let dictionary = snapshot.value as! [String: Any]
            print(dictionary)
            print(snapshot)
            
        }, withCancel: { (error) in
            print(error)
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let childRef = FIRDatabase.database().reference(withPath: "users")
        
        userRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                
                let json = JSON(item)
                print(json)
            }
        })
    }
    
    func getCity() -> String {
        
        return self.city
    }
    func getPostalCode() -> String {
        
        return self.postalCode
    }
    func getCountryCode() -> String {
        
        return self.countryCode
    }
    func getLocation() -> CLLocation {
        
        getUserLocation()
        return location
    }
    func getLat() -> CLLocationDegrees {
        
        return location.coordinate.latitude
    }
    func getLong() -> CLLocationDegrees{
        
        return location.coordinate.longitude
    }
    func getUserHomeLocation(address: String) -> CLLocation  {
        
        coordinatesFromAdress(address: address)
        return userHomeLocation
    }
    func getUserDatabaseAdress(uid: String) -> String {
       
        retrieveUserDatabaseAdress(userID: uid)
        return address
    }
    
    init() {
        
        location = CLLocation(latitude: 0.0, longitude: 0.0)
        city = ""
        postalCode = ""
        countryCode = ""
        address = ""
    }
    
    
}
