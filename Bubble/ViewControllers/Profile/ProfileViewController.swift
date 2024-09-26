//
//  ProfileViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 23/09/24.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var imgvwUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var imgVwVerify: UIImageView!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var vwRatings: UIView!
    @IBOutlet weak var vwPost: UIView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnRatings: UIButton!
    
    var objUser : UserModel?
    var arrDashboard = [DashboardModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.call_WsGetProfile()
        self.call_GetPost_Api()
        let nibTbl = UINib(nibName: "DashboardTableViewCell", bundle: nil)
        self.tblVw.register(nibTbl, forCellReuseIdentifier: "DashboardTableViewCell")
    }

    @IBAction func btnOnEditProfile(_ sender: Any) {
        self.pushVc(viewConterlerId: "EditProfileViewController")
    }
    
    @IBAction func btnOnPost(_ sender: Any) {
        resetImage()
        self.vwPost.backgroundColor = .white
        self.btnPost.setTitleColor(UIColor(named: "appColor"), for: .normal)
    }
    
    @IBAction func btnOnRatings(_ sender: Any) {
        resetImage()
        self.vwRatings.backgroundColor = .white
        self.btnRatings.setTitleColor(UIColor(named: "appColor"), for: .normal)
    }
    
    func resetImage(){
        self.vwPost.backgroundColor = UIColor(named: "appColor")
        self.vwRatings.backgroundColor = UIColor(named: "appColor")
        
        self.btnPost.setTitleColor(.white, for: .normal)
        self.btnRatings.setTitleColor(.white, for: .normal)
        
        
    }
}


extension ProfileViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDashboard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath)as! DashboardTableViewCell
        
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
        cell.btnOnShare.tag = indexPath.row
        cell.btnOpenMenu.tag = indexPath.row
        
        
//        cell.btnOnMsg.addTarget(self, action: #selector(btnActionOnMessage(sender:)), for: .touchUpInside)
//        cell.btnMeter.addTarget(self, action: #selector(btnActionOnMeter(sender:)), for: .touchUpInside)
//        cell.btnOnFav.addTarget(self, action: #selector(btnActionOnFav(sender:)), for: .touchUpInside)
//        cell.btnOnShare.addTarget(self, action: #selector(btnActionOnShare(sender:)), for: .touchUpInside)
//        cell.btnOpenMenu.addTarget(self, action: #selector(btnActionOnMenu(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushVc(viewConterlerId: "TestViewController")
    }
}


extension ProfileViewController{
    
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
                    self.lblName.text = self.objUser?.name
                    self.lblGender.text = self.objUser?.gender
                    self.lblBio.text = self.objUser?.strBio
                    
                    if self.objUser?.blue_tick_status == "APPROVED"{
                        self.imgVwVerify.isHidden = false
                    }else{
                        self.imgVwVerify.isHidden = true
                    }
                    
                    let imageUrl  = self.objUser?.user_image
                    if imageUrl != "" {
                        let url = URL(string: imageUrl ?? "")
                        self.imgvwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
                    }else{
                        self.imgvwUser.image = #imageLiteral(resourceName: "logo")
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
    
    func call_GetPost_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["login_user_id":objAppShareData.UserDetail.strUser_id,
                         "lat":"",
                         "lng":"",
                         "hashtag":"",
                         "distance":""]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_getPost, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [[String:Any]] {
                    self.arrDashboard.removeAll()
                    for data in user_details{
                        let obj = DashboardModel.init(from: data)
                        if obj.id == objAppShareData.UserDetail.strUser_id{
                            self.arrDashboard.append(obj)
                        }
                        
                    }
                    self.arrDashboard = self.arrDashboard.reversed()
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
