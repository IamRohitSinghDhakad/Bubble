//
//  NotificationViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 23/09/24.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var tblNotification: UITableView!
    
    var arrNotificationModel = [NotificationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.call_GetNotification_Api()
    }


}


extension NotificationViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotificationModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath)as! NotificationTableViewCell
        
        cell.lblTitle.text = self.arrNotificationModel[indexPath.row].message
        
        return cell
    }
}


extension NotificationViewController {
    
    func call_GetNotification_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["login_user_id":objAppShareData.UserDetail.strUser_id]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_GetNotofication, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [[String:Any]] {
                    self.arrNotificationModel.removeAll()
                    for data in user_details{
                        let obj = NotificationModel.init(from: data)
                        self.arrNotificationModel.append(obj)
                    }
                   
                    self.tblNotification.reloadData()
                    
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
