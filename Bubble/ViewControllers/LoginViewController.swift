//
//  LoginViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 16/09/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tfEmail.text = "shubhamshrimal4@gmail.com"
        self.tfPassword.text = "Qwerty@123"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnOnLogin(_ sender: Any) {
        if self.validateFields(){
            self.call_WsLogin()
        }
    }
    
    @IBAction func btnOnForgotPassword(_ sender: Any) {
        self.pushVc(viewConterlerId: "ForgotPasswordViewController")
    }
    
    @IBAction func btnDonthaveaccount(_ sender: Any) {
        self.pushVc(viewConterlerId: "SignUpViewController")
    }
    
    
    func validateFields() -> Bool {
        guard let email = tfEmail.text, !email.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Please Enter Email".localized(), controller: self)
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            // Show an error message for invalid email format
            objAlert.showAlert(message: "Email is not valid".localized(), controller: self)
            return false
        }
        
        guard let password = tfPassword.text, !password.isEmpty else {
            // Show an error message for empty password
            objAlert.showAlert(message: "Please Enter Password".localized(), controller: self)
            return false
        }
        
        // All validations pass
        return true
    }
    
}


extension LoginViewController{
    
    func call_WsLogin(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        var dicrParam = [String:Any]()
        
        var url = ""
        
            dicrParam = ["email":self.tfEmail.text!,
                         "password":self.tfPassword.text!,
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
