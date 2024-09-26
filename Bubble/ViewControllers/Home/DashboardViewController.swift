//
//  DashboardViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 17/09/24.
//

import UIKit
import SDWebImage
import CoreLocation

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var cvCards: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var vwTbl: UIView!
    @IBOutlet weak var vwCv: UIView!
    @IBOutlet var subVw: UIView!
    @IBOutlet var subVwVoting: UIView!
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var lblCounter: UILabel!
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var arrDashboard = [DashboardModel]()
    var arrComments = [CommentsModel]()
    var strLatitude = ""
    var strLongitude = ""
    var strSelectedIndex = -1
    var isComingFromAddComment = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.setupLocationManager()
        
        let nib = UINib(nibName: "DashboardCollectionViewCell", bundle: nil)
        self.cvCards.register(nib, forCellWithReuseIdentifier: "DashboardCollectionViewCell")
        
        let nibTbl = UINib(nibName: "DashboardTableViewCell", bundle: nil)
        self.tblVw.register(nibTbl, forCellReuseIdentifier: "DashboardTableViewCell")
        
        self.vwCv.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.call_GetPost_Api()
        
    }
    
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
    @IBAction func btnToggleViews(_ sender: Any) {
        
        self.vwTbl.isHidden = self.vwTbl.isHidden == true ? false : true
        self.vwCv.isHidden = self.vwCv.isHidden == true ? false : true
        
        self.cvCards.reloadData()
        self.view.layoutIfNeeded()
        
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

extension DashboardViewController : CLLocationManagerDelegate{
    
    // Setup the location manager and request permission if needed
    func setupLocationManager() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self?.checkLocationAuthorizationStatus()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlertForLocationServicesDisabled()
                }
            }
        }
    }
    
    // Check the authorization status for location access
    func checkLocationAuthorizationStatus() {
        guard let locationManager = locationManager else { return }
        print(locationManager)
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Request permission
        case .restricted, .denied:
            showAlertForLocationPermissionDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError("Unhandled case for location authorization status.")
        }
    }
    
    // CLLocationManagerDelegate method - called when location updates are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationManager?.stopUpdatingLocation() // Stop updates to save battery
            self.strLatitude = "\(currentLocation?.coordinate.latitude ?? 0.0)"
            self.strLongitude = "\(currentLocation?.coordinate.longitude ?? 0.0)"
            self.call_GetPost_Api()
        }
    }
    
    // Handle location update failure
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        showAlertForLocationError(error)
    }
    
    //      // Calculate distance once location is obtained
    //      func calculateDistance(toLatitude latitude: Double, longitude: Double) {
    //          guard let currentLocation = currentLocation else {
    //              print("Current location is not available.")
    //              return
    //          }
    //
    //          let distanceInKm = currentLocation.distanceTo(latitude: latitude, longitude: longitude)
    //          print("Distance: \(distanceInKm) km")
    //      }
    
    // Convert String lat/long to Double and calculate the distance
    func calculateDistanceToDestination(latitudeString: String, longitudeString: String) -> String? {
        guard let latitude = Double(latitudeString), let longitude = Double(longitudeString) else {
            print("Invalid latitude or longitude format.")
            return nil
        }
        
        guard let currentLocation = currentLocation else {
            print("Current location is not available.")
            return nil
        }
        
        let distanceInKm = currentLocation.distanceTo(latitude: latitude, longitude: longitude)
        let formattedDistance = String(format: "%.2f", distanceInKm) // Format to 2 decimal places
        return "\(formattedDistance) km"
    }
    
    // Show alert if location services are disabled
    func showAlertForLocationServicesDisabled() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Show alert if location permission is denied
    func showAlertForLocationPermissionDenied() {
        let alert = UIAlertController(title: "Location Permission Denied", message: "Please enable location access in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Show alert for any other location errors
    func showAlertForLocationError(_ error: Error) {
        let alert = UIAlertController(title: "Location Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

//For Table View
extension DashboardViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblComments{
            return self.arrComments.count
        }else{
            return self.arrDashboard.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tblComments{
            
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
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell")as! DashboardTableViewCell
            
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
            
            let distance = self.calculateDistanceToDestination(latitudeString: obj.lat ?? "", longitudeString: obj.lng ?? "")
            cell.lblDistance.text = distance
            
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
        }
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
        self.addSubviewVoting(isAdd: true)
    }
    
    @objc func btnActionOnFav(sender: UIButton){
        self.strSelectedIndex = sender.tag
        print("Button pressed-----at Index number------->",sender.tag)
        print(self.arrDashboard[sender.tag].user_name!)
    }
    
    @objc func btnActionOnShare(sender: UIButton){
        self.strSelectedIndex = sender.tag
        print("Button pressed-----at Index number------->",sender.tag)
        print(self.arrDashboard[sender.tag].user_name!)
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
                print("User click Delete button")
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
//For Collection View

extension DashboardViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrDashboard.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollectionViewCell", for: indexPath)as! DashboardCollectionViewCell
        
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
        cell.lblHasTag.text = obj.arrHasTag.joined(separator: "")
        
        let distance = self.calculateDistanceToDestination(latitudeString: obj.lat ?? "", longitudeString: obj.lng ?? "")
        cell.lblDistance.text = distance
        //print("distance==============>>>>>", distance ?? "")
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pushVc(viewConterlerId: "DetailViewController")
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 1
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let width = (collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow)
        var height = collectionView.bounds.height
        
        return CGSize(width: width, height: height)
    }
    
}


extension DashboardViewController {
    
    
    func call_GetPost_Api(){
        
        if !objWebServiceManager.isNetworkAvailable(){
            objWebServiceManager.hideIndicator()
            objAlert.showAlert(message: "No Internet Connection", title: "Alert", controller: self)
            return
        }
        
        objWebServiceManager.showIndicator()
        
        let dicrParam = ["login_user_id":objAppShareData.UserDetail.strUser_id,
                         "lat":self.strLatitude,
                         "lng":self.strLongitude,
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
                        self.arrDashboard.append(obj)
                    }
                    self.arrDashboard = self.arrDashboard.reversed()
                    self.cvCards.reloadData()
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
}


extension CLLocation {
    /// Calculates the distance from the current location to a given latitude and longitude in kilometers.
    /// - Parameters:
    ///   - latitude: The latitude of the destination.
    ///   - longitude: The longitude of the destination.
    /// - Returns: Distance in kilometers as a Double.
    func distanceTo(latitude: Double, longitude: Double) -> Double {
        let destinationLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = self.distance(from: destinationLocation)
        return distanceInMeters / 1000.0 // Convert meters to kilometers
    }
}


extension DashboardViewController{
    
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
