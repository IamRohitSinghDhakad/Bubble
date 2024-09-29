//
//  ProfileViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 23/09/24.
//
enum DisplayMode {
    case post
    case rating
    case comments
}

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
    //---------------------------------------//
    @IBOutlet var subVw: UIView!
    @IBOutlet var subVwVoting: UIView!
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var lblCounter: UILabel!
    //---------------------------------------//
    var arrComments = [CommentsModel]()
    var objUser : UserModel?
    var arrDashboard = [DashboardModel]()
    var arrRatings = [RatingModel]()
    var strSelectedIndex = -1
    var isComingFromAddComment = false
    var currentDisplayMode: DisplayMode = .post
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibTbl = UINib(nibName: "DashboardTableViewCell", bundle: nil)
        self.tblVw.register(nibTbl, forCellReuseIdentifier: "DashboardTableViewCell")
        
        let nibRating = UINib(nibName: "RatingTableViewCell", bundle: nil)
        self.tblVw.register(nibRating, forCellReuseIdentifier: "RatingTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.call_WsGetProfile()
        self.call_GetPost_Api()
        self.call_GetRatings_Api()
    }
    
    @IBAction func btnOnEditProfile(_ sender: Any) {
        self.pushVc(viewConterlerId: "EditProfileViewController")
    }
    
    @IBAction func btnOnPost(_ sender: Any) {
        currentDisplayMode = .post
        self.tblVw.reloadData()
        resetImage()
        self.vwPost.backgroundColor = .white
        self.btnPost.setTitleColor(UIColor(named: "appColor"), for: .normal)
    }
    
    @IBAction func btnOnRatings(_ sender: Any) {
        currentDisplayMode = .rating
        self.tblVw.reloadData()
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
    
    //MARK: SubVwButton Actions
    @IBAction func sliderVoting(_ sender: UISlider) {
        self.lblCounter.text = "\(Int(sender.value))"
    }
    @IBAction func btnOnSubmitVoting(_ sender: Any) {
        call_AddVote_Api(strPostId: self.arrDashboard[strSelectedIndex].post_id ?? "")
    }
    
    @IBAction func btnOnCloseVotingVw(_ sender: Any) {
        self.strSelectedIndex = -1
        self.addSubviewVoting(isAdd: false)
    }
    @IBAction func btnCloseSubVw(_ sender: Any) {
        self.call_GetPost_Api()
        self.isComingFromAddComment = false
        self.strSelectedIndex = -1
        self.tabBarController?.tabBar.isHidden = false
        self.addSubview(isAdd: false)
    }
    
    @IBAction func btnSendComment(_ sender: Any) {
        self.call_AddComments_Api(strPostId: self.arrDashboard[strSelectedIndex].post_id ?? "")
    }
}


extension ProfileViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblComments{
            return self.arrComments.count
        }else if currentDisplayMode == .post{
            return self.arrDashboard.count
        }else{
            return self.arrRatings.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch currentDisplayMode {
        case .post:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath)as! DashboardTableViewCell
            cell.lblDistance.isHidden = true
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
            
            if obj.favourite == "0"{
                cell.imgVwFav.image = #imageLiteral(resourceName: "star2")
            }else{
                cell.imgVwFav.image = #imageLiteral(resourceName: "star")
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
            
            
            cell.btnOnMsg.addTarget(self, action: #selector(btnActionOnMessage(sender:)), for: .touchUpInside)
            cell.btnMeter.addTarget(self, action: #selector(btnActionOnMeter(sender:)), for: .touchUpInside)
            cell.btnOnFav.addTarget(self, action: #selector(btnActionOnFav(sender:)), for: .touchUpInside)
            cell.btnOnShare.addTarget(self, action: #selector(btnActionOnShare(sender:)), for: .touchUpInside)
            cell.btnOpenMenu.addTarget(self, action: #selector(btnActionOnMenu(sender:)), for: .touchUpInside)
            
            return cell
        case .comments:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell")as! CommentsTableViewCell
            
            let obj = self.arrComments[indexPath.row]
            
            cell.lblComment.text = obj.comment
            cell.lblTimeAgo.text = obj.time_ago
            cell.lblUserName.text = obj.user_name
            
            let imageUrl  = obj.user_image
            if imageUrl != "" {
                let url = URL(string: imageUrl ?? "")
                cell.imgVwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
            }else{
                cell.imgVwUser.image = #imageLiteral(resourceName: "logo")
            }
            
            return cell
        case.rating:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath)as! RatingTableViewCell
            
            let obj = self.arrRatings[indexPath.row]
            
            
            let imageUrl  = obj.user_image
            if imageUrl != "" {
                let url = URL(string: imageUrl ?? "")
                cell.imgVwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
            }else{
                cell.imgVwUser.image = #imageLiteral(resourceName: "logo")
            }
            
            cell.lblRatinGComment.text = obj.review
            cell.vwRating.rating = 5
            
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController")as! DetailViewController
        vc.obj = self.arrDashboard[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: -Table Button Actions
    
    @objc func btnActionOnMessage(sender: UIButton){
        self.strSelectedIndex = sender.tag
        self.call_GetComments_Api(strPostId: self.arrDashboard[sender.tag].post_id ?? "")
        print("Button pressed-----at Index number------->",sender.tag)
        print(self.arrDashboard[sender.tag].user_name!)
    }
    
    @objc func btnActionOnMeter(sender: UIButton){
        self.strSelectedIndex = sender.tag
        print("Button pressed-----at Index number------->",sender.tag)
        print(self.arrDashboard[sender.tag].user_name!)
        
        if self.arrDashboard[sender.tag].voted == "0"{
            self.addSubviewVoting(isAdd: true)
        }else{
            objAlert.showAlert(message: "You already voted this post", controller: self)
        }
    }
    
    @objc func btnActionOnFav(sender: UIButton){
        self.strSelectedIndex = sender.tag
        print("Button pressed-----at Index number------->",sender.tag)
        self.call_AddFavorite_Api(strPost_id: "\(self.arrDashboard[sender.tag].post_id!)")
    }
    
    @objc func btnActionOnShare(sender: UIButton){
        self.strSelectedIndex = sender.tag
        let str = "\(self.arrDashboard[sender.tag].user_name!)\n" + "\(self.arrDashboard[sender.tag].strDescription!)\n"
        let description = str
        let appLink = "https://yourappstorelink.com"  // Replace with your app store link
        
        presentShareSheet(description: description, appLink: appLink)
    }
    
    @objc func btnActionOnMenu(sender: UIButton){
        self.strSelectedIndex = sender.tag
        print("Button pressed-----at Index number------->",sender.tag)
        print(self.arrDashboard[sender.tag].user_name!)
        self.openActionSheet(index: "\(sender.tag)", userID: "\(self.arrDashboard[sender.tag].id ?? "")", strPostID: "\(self.arrDashboard[sender.tag].post_id ?? "")")
    }
    
    func openActionSheet(index:String, userID: String, strPostID:String){
        
        let alert = UIAlertController(title: "Alert", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        if userID == objAppShareData.UserDetail.strUser_id{
            alert.addAction(UIAlertAction(title: "Delete Post", style: .default , handler:{ (UIAlertAction)in
                objAlert.showAlertCallBack(alertLeftBtn: "Yes", alertRightBtn: "No", title: "Delete Alert", message: "Are you sure you want to delete this post?", controller: self) {
                    self.call_DeletePost_Api(strPost_id: strPostID)
                }
                
            }))
        }else{
            alert.addAction(UIAlertAction(title: "Report", style: .default , handler:{ (UIAlertAction)in
                print("User click Approve button")
            }))
            
            alert.addAction(UIAlertAction(title: "Block User", style: .default , handler:{ (UIAlertAction)in
                print("User click Edit button")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            print("User click Cancel button")
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
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
        
        let finalUrl = "\(WsUrl.url_getPost)login_user_id=\(objAppShareData.UserDetail.strUser_id)&lat=&lng=&hashtag=&distance="
        
        objWebServiceManager.requestPost(strURL: finalUrl, queryParams: [:], params: [:], strCustomValidation: "", showIndicator: false) { response in
            
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
    
    
    
    //=============================== XXXXXX =================================////
    
    //MARK: Comments WebService
    
    func call_GetComments_Api(strPostId:String){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["post_id":strPostId]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_GetComments, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [[String:Any]] {
                    self.arrComments.removeAll()
                    for data in user_details{
                        let obj = CommentsModel.init(from: data)
                        self.arrComments.append(obj)
                    }
                    self.tblComments.displayBackgroundText(text: "")
                    self.tblComments.reloadData()
                    self.tabBarController?.tabBar.isHidden = true
                    if self.isComingFromAddComment == true{
                        
                    }else{
                        self.addSubview(isAdd: true)
                    }
                    
                    
                    
                }
                else {
                    objAlert.showAlert(message: "Something went wrong!", title: "", controller: self)
                }
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    self.arrComments.removeAll()
                    self.tblComments.reloadData()
                    self.tabBarController?.tabBar.isHidden = true
                    self.addSubview(isAdd: true)
                    self.tblComments.displayBackgroundText(text: "No Comments Yet!")
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
    
    //MARK: -Add Comment
    func call_AddComments_Api(strPostId:String){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["post_id":strPostId,
                         "user_id":objAppShareData.UserDetail.strUser_id,
                         "comment":self.tfComment.text!]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_add_comment, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [String:Any]{
                    self.isComingFromAddComment = true
                    self.tfComment.text = ""
                    self.call_GetComments_Api(strPostId: strPostId)
                }
                else {
                    objAlert.showAlert(message: "Something went wrong!", title: "", controller: self)
                }
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
    
    //MARK: -Add Vote
    func call_AddVote_Api(strPostId:String){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["post_id":strPostId,
                         "user_id":objAppShareData.UserDetail.strUser_id,
                         "vote_scale":self.lblCounter.text!]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_add_vote, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                self.call_GetPost_Api()
                self.addSubviewVoting(isAdd: false)
                self.strSelectedIndex = -1
                
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
    
    //MARK: - Delete Post API
    func call_DeletePost_Api(strPost_id:String){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["login_user_id":objAppShareData.UserDetail.strUser_id,
                         "post_id":strPost_id]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_DeletePost, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                self.call_GetPost_Api()
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    self.call_GetPost_Api()
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
    
    //MARK: -
    func call_AddFavorite_Api(strPost_id:String){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["user_id":objAppShareData.UserDetail.strUser_id,
                         "post_id":strPost_id]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_AddFavorite, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                self.call_GetPost_Api()
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    self.call_GetPost_Api()
                }else{
                    objAlert.showAlert(message: message ?? "", title: "", controller: self)
                }
            }
            
            
        } failure: { (Error) in
            //  print(Error)
            objWebServiceManager.hideIndicator()
        }
    }
    
    //MARK: Get ratings
    func call_GetRatings_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["user_id":objAppShareData.UserDetail.strUser_id]as [String:Any]
        
        objWebServiceManager.requestPost(strURL: WsUrl.url_GetRatings, queryParams: [:], params: dicrParam, strCustomValidation: "", showIndicator: false) { (response) in
            objWebServiceManager.hideIndicator()
            
            let status = (response["status"] as? Int)
            let message = (response["message"] as? String)
            print(response)
            
            if status == MessageConstant.k_StatusCode{
                if let user_details  = response["result"] as? [[String:Any]] {
                    self.arrRatings.removeAll()
                    for data in user_details{
                        let obj = RatingModel.init(from: data)
                        self.arrRatings.append(obj)
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

extension ProfileViewController{
    
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
    
    func addSubviewVoting(isAdd: Bool) {
        if isAdd {
            self.subVwVoting.frame = CGRect(x: 0, y: -(self.view.frame.height), width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(subVwVoting)
            
            UIView.animate(withDuration: 0.5) {
                self.subVwVoting.frame.origin.y = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.subVwVoting.frame.origin.y = self.view.frame.height
            } completion: { y in
                self.subVwVoting.removeFromSuperview()
            }
        }
    }
    
}
