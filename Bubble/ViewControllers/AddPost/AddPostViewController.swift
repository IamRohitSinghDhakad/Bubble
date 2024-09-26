//
//  AddPostViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 23/09/24.
//

import UIKit
import CoreLocation

class AddPostViewController: UIViewController {

    @IBOutlet var subVw: UIView!
    @IBOutlet weak var tfAddHastag: UITextField!
    @IBOutlet weak var tfDesc: RDTextView!
    @IBOutlet weak var lblHastags: UILabel!
    
    var arrStringHastag = [String]()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var strLatitude = ""
    var strLongitude = ""
    var strAddress = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.setupLocationManager()
        
    }
    
    @IBAction func btnCloseSubVw(_ sender: Any) {
        self.view.endEditing(true)
        self.addSubview(isAdd: false)
    }
    
    @IBAction func btnOnAddHastag(_ sender: Any) {
        self.view.endEditing(true)
        let strHastag = "#"+self.tfAddHastag.text!
        self.arrStringHastag.append(strHastag)
        self.lblHastags.text = "\(self.arrStringHastag.joined(separator: ""))"
        self.tfAddHastag.text = ""
        self.addSubview(isAdd: false)
    }
    
    @IBAction func btnDeleteAllHastags(_ sender: Any) {
        self.view.endEditing(true)
        self.arrStringHastag.removeAll()
        self.tfAddHastag.text = ""
        self.lblHastags.text = ""
    }
    @IBAction func btnOnSubmit(_ sender: Any) {
        self.view.endEditing(true)
        if validateFields(){
            self.call_AddPost_Api()
        }
    }
    
    @IBAction func btnOnOpenSubVw(_ sender: Any) {
        if self.arrStringHastag.count >= 5{
            objAlert.showAlert(message: "Limit exceed".localized(), controller: self)
        }else{
            self.addSubview(isAdd: true)
            self.view.endEditing(true)
            self.tfAddHastag.becomeFirstResponder()
        }
       
    }
    
    func validateFields() -> Bool {
        
        guard let desc = tfDesc.text, !desc.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter description".localized(), controller: self)
            return false
        }
        
        guard let hastag = lblHastags.text, !hastag.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter hastag".localized(), controller: self)
            return false
        }
        
        // All validations pass
        return true
    }
    
    
}


extension AddPostViewController{
    
    func addSubview(isAdd: Bool) {
        if isAdd {
            self.subVw.frame = CGRect(x: 0, y: -(self.view.frame.height), width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(subVw)
            
            UIView.animate(withDuration: 0.5) {
                self.subVw.frame.origin.y = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.subVw.frame.origin.y = self.view.frame.height
            } completion: { y in
                self.subVw.removeFromSuperview()
            }
        }
    }
    
}


extension AddPostViewController{
    
    func call_AddPost_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["user_id":objAppShareData.UserDetail.strUser_id,
                         "description":self.tfDesc.text!,
                         "lat":self.strLatitude,
                         "lng":self.strLongitude,
                         "hashtag":self.lblHastags.text!,
                         "address":self.strAddress]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_AddPost, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [String:Any] {
                    objAlert.showAlert(message: "Post added succesfully", controller: self)
                    self.lblHastags.text = ""
                    self.tfDesc.text = ""
                    self.view.endEditing(true)
                }
                else {
                    objAlert.showAlert(message: "Something went wrong!", title: "", controller: self)
                }
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    objAlert.showAlert(message: msgg, title: "", controller: self)
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
}


extension AddPostViewController : CLLocationManagerDelegate{
    
    // Setup the location manager and request permission if needed
    func setupLocationManager() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self?.checkLocationAuthorizationStatus()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlertForLocationServicesDisabled()
                }
            }
        }
    }
    
    // Check the authorization status for location access
    func checkLocationAuthorizationStatus() {
        guard let locationManager = locationManager else { return }
        print(locationManager)
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Request permission
        case .restricted, .denied:
            showAlertForLocationPermissionDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError("Unhandled case for location authorization status.")
        }
    }
    
    // CLLocationManagerDelegate method - called when location updates are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationManager?.stopUpdatingLocation() // Stop updates to save battery
            self.strLatitude = "\(currentLocation?.coordinate.latitude ?? 0.0)"
            self.strLongitude = "\(currentLocation?.coordinate.longitude ?? 0.0)"
            
            LocationService.shared.getAddressFromLatLong(plLatitude:  self.strLatitude, plLongitude: self.strLongitude, completion: { (dictAddress) in
                
                let locality = dictAddress["locality"]as? String
                let SubLocality = dictAddress["subLocality"]as? String
                let throughFare = dictAddress["thoroughfare"]as? String
                
                if locality != ""{
                    self.strAddress = locality ?? ""
                }else{
                    if SubLocality != ""{
                        self.strAddress = SubLocality ?? ""
                    }else{
                        if throughFare != ""{
                            self.strAddress = throughFare ?? ""
                        }
                    }
                }
                if let fullAddress = dictAddress["fullAddress"]as? String{
                    self.strAddress = fullAddress
                }else{
                    self.strAddress = dictAddress["country"]as? String ?? ""
                }
                
                LocationService.shared.stopUpdatingLocation()
                
            }) { (Error) in
                print(Error)
            }
            
            print("Address is --------->>>>>>>>",strAddress)
           
        }
    }
    
    // Handle location update failure
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        showAlertForLocationError(error)
    }
    
    // Show alert if location services are disabled
    func showAlertForLocationServicesDisabled() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Show alert if location permission is denied
    func showAlertForLocationPermissionDenied() {
        let alert = UIAlertController(title: "Location Permission Denied", message: "Please enable location access in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Show alert for any other location errors
    func showAlertForLocationError(_ error: Error) {
        let alert = UIAlertController(title: "Location Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
