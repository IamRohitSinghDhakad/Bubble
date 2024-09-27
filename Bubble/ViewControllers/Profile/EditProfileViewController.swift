//
//  EditProfileViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 25/09/24.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var txtVwBio: RDTextView!
    @IBOutlet weak var imgVwMale: UIImageView!
    @IBOutlet weak var imgVwFemale: UIImageView!
    
    var objUser : UserModel?
    var strSelectedGender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.call_WsGetProfile()
    
        self.tfEmail.isUserInteractionEnabled = false
        
    }
    
    @IBAction func btnOnGoBack(_ sender: Any) {
        self.onBackPressed()
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
    @IBAction func btnOpenImage(_ sender: Any) {
        MediaPicker.shared.pickMedia(from: self) { image in
            self.imgVwUser.image = image
        }
    }
    
    @IBAction func btnOnSubmit(_ sender: Any) {
        if validateFields(){
            self.callWebserviceForUpdateProfile()
        }
    }
    
    
    func validateFields() -> Bool {
        
        guard let userName = tfName.text, !userName.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Name".localized(), controller: self)
            return false
        }
        
        guard let mobile = tfMobile.text, !mobile.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Mobile".localized(), controller: self)
            return false
        }
        
        guard let strBio = txtVwBio.text, !strBio.isEmpty else {
            // Show an error message for empty email
            objAlert.showAlert(message: "Enter Bio".localized(), controller: self)
            return false
        }
        // All validations pass
        return true
    }
    
    
}


extension EditProfileViewController{
    
    func call_WsGetProfile(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        var dicrParam = [String:Any]()
        
        var url = ""
        
        dicrParam = ["user_id":objAppShareData.UserDetail.strUser_id,
                     "login_user_id":objAppShareData.UserDetail.strUser_id]as [String:Any]
        
        url = WsUrl.url_getUserProfile
        
        
        print(dicrParam)
        
        objWebServiceManager.requestPost(strURL: url, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [String:Any] {
                    
                    self.objUser = UserModel.init(from: user_details)
                    self.tfName.text = self.objUser?.name
                    self.tfEmail.text = self.objUser?.strEmail
                    self.tfMobile.text = self.objUser?.mobile
                    self.txtVwBio.text = self.objUser?.strBio
                    
                    let imageUrl  = self.objUser?.user_image
                    if imageUrl != "" {
                        let url = URL(string: imageUrl ?? "")
                        self.imgVwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
                    }else{
                        self.imgVwUser.image = #imageLiteral(resourceName: "logo")
                    }
                    
                    if self.objUser?.gender == "Male"{
                        self.imgVwMale.image = #imageLiteral(resourceName: "select")
                        self.imgVwFemale.image = #imageLiteral(resourceName: "circle_white")
                        self.strSelectedGender = "Male"
                    }else{
                        self.imgVwFemale.image = #imageLiteral(resourceName: "select")
                        self.imgVwMale.image = #imageLiteral(resourceName: "circle_white")
                        self.strSelectedGender = "Female"
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
    
    
    func callWebserviceForUpdateProfile(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        objWebServiceManager.showIndicator()
        self.view.endEditing(true)
        
        var imageData = [Data]()
        var imgData : Data?
        if self.imgVwUser != nil{
            imgData = (self.imgVwUser.image?.jpegData(compressionQuality: 0.2))!
        }
        else {
            imgData = (self.imgVwUser.image?.jpegData(compressionQuality: 0.2))!
        }
        imageData.append(imgData!)
        
        let imageParam = ["user_image"]
        
        let dicrParam = ["user_id":objAppShareData.UserDetail.strUser_id,
                         "name":self.tfName.text!,
                         "bio":self.txtVwBio.text!,
                         "mobile":self.tfMobile.text!,
                         "gender":self.strSelectedGender]as [String:Any]
        
        print(dicrParam)
        
        objWebServiceManager.uploadMultipartWithImagesData(strURL: WsUrl.url_UpdateProfile, params: dicrParam, showIndicator: true, customValidation: "", imageData: imgData, imageToUpload: imageData, imagesParam: imageParam, fileName: "user_image", mimeType: "image/jpeg") { (response) in
            objWebServiceManager.hideIndicator()
            print(response)
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            
            if status == MessageConstant.k_StatusCode{
                
                
                guard let user_details  = response["result"] as? [String:Any] else{
                    return
                }
                
                objAlert.showAlertSingleButtonCallBack(alertBtn: "OK".localized(), title: "Profile Updated", message: "Your profile is updated successfully", controller: self) {
                    self.onBackPressed()
                }
                
                
            }else{
                objWebServiceManager.hideIndicator()
                objAlert.showAlert(message: response["result"] as? String ?? "", title: "Alert", controller: self)
            }
        } failure: { (Error) in
            print(Error)
        }
    }
}
