//
//  DetailViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 24/09/24.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgVwVerified: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblHastag: UILabel!
    @IBOutlet weak var imgVwFav: UIImageView!
    @IBOutlet weak var lblVoting: UILabel!
    @IBOutlet weak var lblMsgCount: UILabel!
    @IBOutlet var subVw: UIView!
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet var subVwVoting: UIView!
    @IBOutlet weak var lblCounter: UILabel!
    
    var obj:DashboardModel?
    var arrComments = [CommentsModel]()
    var isComingFromAddComment = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblComments.delegate = self
        self.tblComments.dataSource = self
        
        self.imgVwVerified.image = #imageLiteral(resourceName: "verify")
        self.lblUsername.text = obj?.user_name
        let imageUrl  = obj?.user_image
        if imageUrl != "" {
            let url = URL(string: imageUrl ?? "")
            self.imgVwUser.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logo"))
        }else{
            self.imgVwUser.image = #imageLiteral(resourceName: "logo")
        }
        
        if obj?.blue_tick_status == "APPROVED"{
            self.imgVwVerified.isHidden = false
        }else{
            self.imgVwVerified.isHidden = true
        }
        
        self.lblDesc.text = obj?.strDescription
        self.lblHastag.text = obj?.arrHasTag.joined(separator: "")
        
        self.lblVoting.text = obj?.average_rating
        self.lblMsgCount.text = obj?.total_comment
        
//        let distance = self.calculateDistanceToDestination(latitudeString: obj.lat ?? "", longitudeString: obj.lng ?? "")
//        cell.lblDistance.text = distance
    }
    

    @IBAction func btnOnBack(_ sender: Any) {
        onBackPressed()
    }
    
    @IBAction func btnOnMenu(_ sender: Any) {
        self.openActionSheet(userID: obj?.id ?? "", strPostID: obj?.post_id ?? "")
    }
    
    
    func openActionSheet(userID: String, strPostID:String){
        
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
    
    @IBAction func btnOnMsg(_ sender: Any) {
    self.call_GetComments_Api(strPostId: obj?.post_id ?? "")
    }
    @IBAction func btnOnVote(_ sender: Any) {
        if self.obj?.voted == "0"{
            self.addSubviewVoting(isAdd: true)
        }else{
            objAlert.showAlert(message: "You already voted this post", controller: self)
        }
    }
    @IBAction func btnOnFav(_ sender: Any) {
        self.call_AddFavorite_Api(strPost_id: obj?.post_id ?? "")
    }
    @IBAction func btnOnShare(_ sender: Any) {
        let str = "\(obj?.user_name! ?? "")\n" + "\(obj?.strDescription! ?? "")\n"
        let description = str
           let appLink = "https://yourappstorelink.com"  // Replace with your app store link
           
           presentShareSheet(description: description, appLink: appLink)
    }
    
    //MARK: - SubVw Button Actions
    @IBAction func btnCloseSubVw(_ sender: Any) {
        self.isComingFromAddComment = false
        self.addSubview(isAdd: false)
    }
    
    @IBAction func btnSendComment(_ sender: Any) {
        self.call_AddComments_Api(strPostId: obj?.post_id ?? "")
    }
    
    
    @IBAction func sliderVoting(_ sender: UISlider) {
        self.lblCounter.text = "\(Int(sender.value))"
    }
    @IBAction func btnOnSubmitVoting(_ sender: Any) {
        call_AddVote_Api(strPostId: obj?.post_id ?? "")
    }
    
    @IBAction func btnOnCloseVotingVw(_ sender: Any) {
        self.addSubviewVoting(isAdd: false)
    }
    
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrComments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
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
        }
    
}


extension DetailViewController{
    
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
                self.onBackPressed()
            }else{
                objWebServiceManager.hideIndicator()
                if let msgg = response["result"]as? String{
                    self.onBackPressed()
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
                self.addSubviewVoting(isAdd: false)
                
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
    
    
    //MARK: - Add favorite API
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
    
}


extension DetailViewController{
    
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
