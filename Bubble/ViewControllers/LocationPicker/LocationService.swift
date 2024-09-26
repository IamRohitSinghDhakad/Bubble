//
//  LocationService.swift
//  Smart Helmet
//
//  Created by Rohit Singh Dhakad on 26/08/20.
//  Copyright © 2020 Systematix Infotech Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: [String:Any])
    func tracingLocationDidFailWithError(error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let shared: LocationService = {
           let instance = LocationService()
           return instance
       }()

    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    var dictUserFinalLocation = [String:Any]()

    override init() {
        super.init()

        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    /// Get Permission from User
    func getPermission() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            return true
        case .denied, .restricted, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    func showAlertOfLocationNotEnabled(){
        let alert = UIAlertController(title: "Alert", message: "Please enable location services from settings.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) )
        alert.addAction(UIAlertAction(title: "Settings", style: .default){ (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.show()
    }
    
    func startUpdatingLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else {return}
        self.lastLocation = location

        
        // use for real time update location
        updateLocation(manager: manager, currentLocation: location)
    }
        
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        updateLocationDidFailWithError(error: error)
    }
    
    // Private function
    private func updateLocation(manager: CLLocationManager, currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        var dictLocation = [String:Any]()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        dictLocation["source_latitude"] = locValue.latitude
        dictLocation["source_longitude"] = locValue.longitude
        dictLocation["source_cordinate"] = self.lastLocation
        self.dictUserFinalLocation = dictLocation
        delegate.tracingLocation(currentLocation: dictLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
    
}

extension LocationService{
    
    func getAddressFromLatLong(plLatitude: String, plLongitude: String, completion:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void){
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(plLatitude)")!
    
        let lon: Double = Double("\(plLongitude)")!
    
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                
                let pm = (placemarks ?? []) as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks?[0]
                    print(pm?.country ?? "")
                    print(pm?.locality ?? "")
                    print(pm?.subLocality ?? "")
                    print(pm?.thoroughfare ?? "")
                    print(pm?.postalCode ?? "")
                    print(pm?.subThoroughfare ?? "")
                    
                    var dictAddress = [String:Any]()
                    var addressString : String = ""
                    
                    if pm?.subLocality != nil {
                        addressString = addressString + (pm?.subLocality!)! + ", "
                        dictAddress["subLocality"] = pm?.subLocality
                    }
                    if pm?.thoroughfare != nil {
                        addressString = addressString + (pm?.thoroughfare!)! + ", "
                        dictAddress["thoroughfare"] = pm?.thoroughfare
                    }
                    if pm?.locality != nil {
                        addressString = addressString + (pm?.locality!)! + ", "
                        dictAddress["locality"] = pm?.locality
                    }
                    if pm?.country != nil {
                        addressString = addressString + (pm?.country!)! + ", "
                        dictAddress["country"] = pm?.country
                    }
                    if pm?.postalCode != nil {
                        addressString = addressString + (pm?.postalCode!)! + " "
                        dictAddress["fullAddress"] = addressString
                    }
                    
                    
                    if dictAddress.count != 0{
                        completion(dictAddress)
                    }else{
                        
                        //failure("Something Wrong Happend! please dubug code :)" as? Error)
                    }
                    
                }
        })
        
    }
    
}
//extension LocationService{
//    
//    func getAddressFromLatLong(plLatitude: String, plLongitude: String, completion:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void){
//        
//        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
//        let lat: Double = Double("\(plLatitude)")!
//    
//        let lon: Double = Double("\(plLongitude)")!
//    
//        let ceo: CLGeocoder = CLGeocoder()
//        center.latitude = lat
//        center.longitude = lon
//        
//        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
//        
//        
////        ceo.reverseGeocodeLocation(loc, completionHandler:
////            {(placemarks, error) in
////                if (error != nil)
////                {
////                    print("reverse geodcode fail: \(error!.localizedDescription)")
////                }
////                let pm = placemarks! as [CLPlacemark]
////
////                if pm.count > 0 {
////                    let pm = placemarks![0]
////                    print(pm.country ?? "")
////                    print(pm.locality ?? "")
////                    print(pm.subLocality ?? "")
////                    print(pm.thoroughfare ?? "")
////                    print(pm.postalCode ?? "")
////                    print(pm.subThoroughfare ?? "")
////
////                    var dictAddress = [String:Any]()
////                    var addressString : String = ""
////
////                    if pm.subLocality != nil {
////                        addressString = addressString + pm.subLocality! + ", "
////                        dictAddress["subLocality"] = pm.subLocality
////                    }
////                    if pm.thoroughfare != nil {
////                        addressString = addressString + pm.thoroughfare! + ", "
////                        dictAddress["thoroughfare"] = pm.thoroughfare
////                    }
////                    if pm.locality != nil {
////                        addressString = addressString + pm.locality! + ", "
////                        dictAddress["locality"] = pm.locality
////                    }
////                    if pm.country != nil {
////                        addressString = addressString + pm.country! + ", "
////                        dictAddress["country"] = pm.country
////                    }
////                    if pm.postalCode != nil {
////                        addressString = addressString + pm.postalCode! + " "
////                        dictAddress["fullAddress"] = addressString
////                    }
////
////
////                    if dictAddress.count != 0{
////                        completion(dictAddress)
////                    }else{
////                        failure("Something Wrong Happend! please dubug code :)" as! Error)
////                    }
////
////                }
////        })
//        
//    }
//    
//}
