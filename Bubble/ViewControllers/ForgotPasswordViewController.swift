//
//  ForgotPasswordViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 16/09/24.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnResetPassword(_ sender: Any) {
        if self.validateFields(){
            self.call_WsForgotPassword()
        }
    }
    
    @IBAction func btnGoBack(_ sender: Any) {
        self.onBackPressed()
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
        
        // All validations pass
        return true
    }
}

// MARK: - Call API
extension ForgotPasswordViewController {
    
    func call_WsForgotPassword(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        var dicrParam = [String:Any]()
        
        
        dicrParam = ["email":self.tfEmail.text!,]as [String:Any]
        
        
        
        objWebServiceManager.requestGet(strURL: WsUrl.url_ForgotPassword, params: dicrParam, queryParams: [:], strCustomValidation: "") { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [String:Any] {
                    
                    objAlert.showAlertSingleButtonCallBack(alertBtn: "OK", title: "", message: "Reset link email sent to your registered email", controller: self) {
                        self.onBackPressed()
                    }
                    
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
