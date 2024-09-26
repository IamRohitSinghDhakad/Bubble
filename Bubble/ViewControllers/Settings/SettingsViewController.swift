//
//  SettingsViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 23/09/24.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    
    var arrSettingsOptions = ["Favorite", "Language", "Privacy Policy", "Terms and Conditions", "Logout", "Delete Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSettingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)as! SettingsTableViewCell
        
        cell.lbltitle.text = self.arrSettingsOptions[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            pushVc(viewConterlerId: "MyFavoriteViewController")
        case 1:
            pushVc(viewConterlerId: "SelectLanguageViewController")
        case 2:
            pushVc(viewConterlerId: "WebViewController")
        case 3:
            pushVc(viewConterlerId: "WebViewController")
        case 4:
            objAlert.showAlertCallBack(alertLeftBtn: "Yes".localized(), alertRightBtn: "No".localized(), title: "Logout alert".localized(), message: "Are you sure you want to logout?".localized(), controller: self) {
                objAppShareData.signOut()
            }
        case 5:
            objAlert.showAlertCallBack(alertLeftBtn: "Yes".localized(), alertRightBtn: "No".localized(), title: "Delete Account".localized(), message: "Are you sure you want to delete your account It will erashe all your records and never restore back?".localized(), controller: self) {
                objAppShareData.signOut()
            }
        default:
            break
        }
        
    }
    
    
    
}

