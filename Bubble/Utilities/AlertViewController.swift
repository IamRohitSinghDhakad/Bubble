//
//  AlertViewController.swift
//  Somi
//
//  Created by Rohit Singh Dhakad on 25/03/21.
//

import UIKit
var objAlert:AlertViewController = AlertViewController()

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(message: String, title: String = "", controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        

        alertController.addAction(OKAction)
        controller.present(alertController, animated: true, completion: nil)
        view.endEditing(true)
    }
    
    // Alert call back function
     func showAlertSingleButtonCallBack(alertBtn:String,  title: String, message: String ,controller: UIViewController, callback: @escaping () -> ()) {
         
         let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
         
          alert.addAction(UIAlertAction(title: alertBtn, style: .default, handler: {
            alertAction in
            callback()
          }))
         
          controller.present(alert, animated: true, completion: nil)
        }
    
    // Alert call back function
     func showAlertCallBack(alertLeftBtn:String, alertRightBtn:String,  title: String, message: String ,controller: UIViewController, callback: @escaping () -> ()) {
         
         let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
         
         if alertLeftBtn != ""{
             alert.addAction(UIAlertAction(title:alertLeftBtn, style: .destructive, handler: {
               alertAction in
                 callback()
             }))
         }else{
            
         }
          alert.addAction(UIAlertAction(title: alertRightBtn, style: .default, handler: {
            alertAction in
           // callback()
          }))
         
          controller.present(alert, animated: true, completion: nil)
        }

    
  // For alert show on UIWindow if you have no Viewcontroller then show this alert.
    func showAlertVc(message: String = "", title: String , controller: UIWindow) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let subView = alertController.view.subviews.first!
            let alertContentView = subView.subviews.first!
            alertContentView.backgroundColor = UIColor.gray
            alertContentView.layer.cornerRadius = 20
            
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            
            
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
//   // Session Expired Alert Show...
//    func showSessionFailAlert() {
//        objWebServiceManager.hideIndicator()
//        let alert = UIAlertController(title: "Session Expired", message: "Please Login Again", preferredStyle: .alert)
//        let yesButton = UIAlertAction(title: "LOGOUT", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//            userDefaults.removeObject(forKey: objAppShareData.UserDetail.straAuthToken)
//            UserDefaults.standard.removeObject(forKey: "Stars")
//            objAppShareData.resetDefaultsAlluserInfo()
//            UserDefaults.standard.setValue(false, forKey: "isDarkMode")
//            objAppDelegate.showLogInNavigation()
//        })
//        alert.addAction(yesButton)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//    }
    
 
    
    
    func showAlert(message: String = "", title: String , controller: UIWindow) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let subView = alertController.view.subviews.first!
            let alertContentView = subView.subviews.first!
            alertContentView.backgroundColor = UIColor.gray
            alertContentView.layer.cornerRadius = 20
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
 }
    
}





