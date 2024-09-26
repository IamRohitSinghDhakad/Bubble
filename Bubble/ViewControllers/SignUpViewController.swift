//
//  SignUpViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 17/09/24.
//

import UIKit
import CoreLocation

class SignUpViewController: UIViewController, LocationServiceDelegate {
   

    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfpassword: UITextField!
    @IBOutlet weak var tfDOB: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgVwMale: UIImageView!
    @IBOutlet weak var imgVwFemale: UIImageView!
    
    let datePicker = UIDatePicker()
    var strSelectedGender = "Male"
    var strLat = ""
    var strLong = ""
    
    var destinationLatitude = Double()
    var destinationLongitude = Double()
    
    var location: Location? {
        didSet {
            self.lblLocation.text = location.flatMap({ $0.title }) ?? "Select Location".localized()
            let cordinates = location.flatMap({ $0.coordinate })
            if (cordinates != nil){
                
                destinationLatitude = cordinates?.latitude ?? 0.0
                destinationLongitude = cordinates?.longitude ?? 0.0
              
                var xCordinate = ""
                var yCordinate = ""
                
                if let latitude = cordinates?.latitude {
                    xCordinate = "\(latitude)"
                }
                if let longitude = cordinates?.longitude{
                    yCordinate = "\(longitude)"
                }
                print(xCordinate)
                print(yCordinate)
                
                LocationService.shared.getAddressFromLatLong(plLatitude: xCordinate, plLongitude: yCordinate, completion: { (dictAddress) in
                    
                    let locality = dictAddress["locality"]as? String
                    let SubLocality = dictAddress["subLocality"]as? String
                    let throughFare = dictAddress["thoroughfare"]as? String
                    
                    if locality != ""{
                        self.lblLocation.text = locality
                    }else{
                        if SubLocality != ""{
                            self.lblLocation.text = SubLocality
                        }else{
                            if throughFare != ""{
                                self.lblLocation.text = throughFare
                            }
                        }
                    }
                    if let fullAddress = dictAddress["fullAddress"]as? String{
                        self.lblLocation.text = fullAddress
                    }else{
                        self.lblLocation.text = dictAddress["country"]as? String ?? ""
                    }
                    
                    LocationService.shared.stopUpdatingLocation()
                    
                }) { (Error) in
                    print(Error)
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfDOB.delegate = self
        self.setDatePicker()
        
        location = nil
        LocationService.shared.delegate = self

        self.imgVwMale.image = #imageLiteral(resourceName: "select")
        self.imgVwFemale.image = #imageLiteral(resourceName: "circle_white")
        self.strSelectedGender = "Male"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnOpenImagePicker(_ sender: Any) {
        MediaPicker.shared.pickMedia(from: self) { image in
            self.imgVwUser.image = image
        }
    }
    
    @IBAction func btnOnMale(_ sender: Any) {
        self.imgVwMale.image = #imageLiteral(resourceName: "select")
        self.imgVwFemale.image = #imageLiteral(resourceName: "circle_white")
        self.strSelectedGender = "Male"
    }
    
    @IBAction func btnOnFemale(_ sender: Any) {
        self.imgVwFemale.image = #imageLiteral(resourceName: "select")
        self.imgVwMale.image = #imageLiteral(resourceName: "circle_white")
        self.strSelectedGender = "Female"
    }
    
    @IBAction func btnOnSignUp(_ sender: Any) {
        if validateFields(){
            self.call_WsSignUp()
        }
    }
    
    @IBAction func btnOnAlreadyHaveanAccount(_ sender: Any) {
        self.onBackPressed()
    }
    
    @IBAction func btnOnLocation(_ sender: Any) {
        self.openLocationPicker()
    }
    
    func openLocationPicker(){
        let sb = UIStoryboard.init(name: "LocationPicker", bundle: Bundle.main)
        let locationPicker = sb.instantiateViewController(withIdentifier: "LocationPickerViewController")as! LocationPickerViewController//segue.destination as! LocationPickerViewController
        locationPicker.location = location
        locationPicker.showCurrentLocationButton = true
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.selectCurrentLocationInitially = true
        
        locationPicker.completion = { self.location = $0 }
        
        self.navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    func tracingLocation(currentLocation: [String : Any]) {
        
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        
    }
    
    func setDatePicker() {
        //Format Date
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.tfDOB.inputAccessoryView = toolbar
        self.tfDOB.inputView = datePicker
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.tfDOB.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func validateFields() -> Bool {
        
        guard let userName = tfUserName.text, !userName.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Name".localized(), controller: self)
            return false
        }
        
        guard let email = tfEmail.text, !email.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Email".localized(), controller: self)
            return false
        }
        
        guard let password = tfpassword.text, !password.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Password".localized(), controller: self)
            return false
        }
        
        
        guard let dob = tfDOB.text, !dob.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Select DOB".localized(), controller: self)
            return false
        }
        
        guard let location = lblLocation.text, !location.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Select Location".localized(), controller: self)
            return false
        }
        // All validations pass
        return true
    }
}


extension SignUpViewController{
    
    func call_WsSignUp(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        var dicrParam = [String:Any]()
        
        var url = ""
        
            dicrParam = ["name":self.tfEmail.text!,
                         "dob":self.tfEmail.text!,
                         "address":self.tfEmail.text!,
                         "lat":self.tfEmail.text!,
                         "lng":self.tfEmail.text!,
                         "gender":self.strSelectedGender,
                         "email":self.tfEmail.text!,
                         "password":self.tfpassword.text!,
                         "ios_register_id":objAppShareData.strFirebaseToken]as [String:Any]
            
            url = WsUrl.url_Login
        
        
        print(dicrParam)
        
        
        
        objWebServiceManager.requestPost(strURL: url, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [String:Any] {
                    
                    objAppShareData.SaveUpdateUserInfoFromAppshareData(userDetail: user_details)
                    objAppShareData.fetchUserInfoFromAppshareData()
                    self.setRootController()
                    
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
    
    func setRootController(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = (self.mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController)!
        let navController = UINavigationController(rootViewController: vc)
        navController.isNavigationBarHidden = true
        appDelegate.window?.rootViewController = navController
    }
    
}
