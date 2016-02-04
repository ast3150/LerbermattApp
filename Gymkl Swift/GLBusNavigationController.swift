//
//  GLBusViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  Controls navigation in "Bus"-Tab

import UIKit
import Foundation
import CoreLocation

class GLBusNavigationController: UINavigationController {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Tab Bar
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Selected)
    
        // Set up CoreLocation
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways: break
        case .AuthorizedWhenInUse: break
        case .NotDetermined: locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Zugriff auf Standort deaktiviert",
                message: "Für das Sortieren der Stationen nach Entfernung und bessere Genauigkeit der Suchresultate, öffne bitte die Einstellungen dieser App und setze den Standortzugriff auf 'Beim Verwenden der App'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Einstellungen öffnen", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension GLBusNavigationController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}