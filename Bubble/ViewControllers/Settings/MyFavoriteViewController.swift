//
//  MyFavoriteViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 24/09/24.
//

import UIKit

class MyFavoriteViewController: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    
    var arrDashboard = [DashboardModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibTbl = UINib(nibName: "MyFavoriteTableViewCell", bundle: nil)
        self.tblVw.register(nibTbl, forCellReuseIdentifier: "MyFavoriteTableViewCell")
    }
    
    @IBAction func btnOnBack(_ sender: Any) {
        onBackPressed()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.call_GetFavorite_Api()
    }
}


extension MyFavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDashboard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewCell", for: indexPath) as! MyFavoriteTableViewCell
        
        let obj = self.arrDashboard[indexPath.row]
        cell.lblName.text = obj.user_name
        let imageUrl  = obj.user_image
        if imageUrl != "" {
            let url = URL(string: imageUrl ?? "")
            cell.imgVwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
        }else{
            cell.imgVwUser.image = #imageLiteral(resourceName: "logo")
        }
        
        if obj.blue_tick_status == "APPROVED"{
            cell.imgvwBlueTick.isHidden = false
        }else{
            cell.imgvwBlueTick.isHidden = true
        }
        
        cell.lblDesciption.text = obj.strDescription
        cell.lblMsgCount.text = obj.total_comment
        cell.lblMeterCount.text = obj.average_rating
        
//        let distance = self.calculateDistanceToDestination(latitudeString: obj.lat ?? "", longitudeString: obj.lng ?? "")
//        cell.lblDistance.text = distance
        
        //Button actions
        cell.btnOnMsg.tag = indexPath.row
        cell.btnMeter.tag = indexPath.row
        cell.btnOnFav.tag = indexPath.row
        cell.btnOpenMenu.tag = indexPath.row
        
        return cell
    }
    
}

extension MyFavoriteViewController{
    
    func call_GetFavorite_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["login_user_id":objAppShareData.UserDetail.strUser_id]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_GetFavorite, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [[String:Any]] {
                    self.arrDashboard.removeAll()
                    for data in user_details{
                        let obj = DashboardModel.init(from: data)
                        self.arrDashboard.append(obj)
                    }
                   
                    self.tblVw.reloadData()
                    
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
