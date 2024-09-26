//
//  AppSharedData.swift
//  FitMate
//
//  Created by Rohit SIngh Dhakad on 18/06/23.
//

import Foundation
import UIKit


let objAppShareData : AppSharedData  = AppSharedData.sharedObject()

class AppSharedData: NSObject {
    
    //MARK: - Shared object
    
    private static var sharedManager: AppSharedData = {
        let manager = AppSharedData()
        return manager
    }()
    
    // MARK: - Accessors
    class func sharedObject() -> AppSharedData {
        return sharedManager
    }
    
    //MARK:- Variables
    var UserDetail = UserModel(from: [:])
    var strFirebaseToken = ""
    var isFromNotification = Bool()
    var isNotificationDict = [String:Any]()
    var dictHomeLocationInfo = [String:Any]()
    var isItemPurchased = Bool()
    var isUpdateProfile = Bool()
    var isUpdateHomeTable = Bool()
    var isLoginAsGuest = Bool()
    var userType = ""
    var uuidString = ""
    
   
    
    open var isLoggedIn: Bool {
        get {
            if (UserDefaults.standard.value(forKey:  UserDefaults.KeysDefault.userInfo) as? [String : Any]) != nil {
                objAppShareData.fetchUserInfoFromAppshareData()
                return true
            }
            return false
        }
    }
    
    // MARK: - saveUpdateUserInfoFromAppshareData ---------------------
    func SaveUpdateUserInfoFromAppshareData(userDetail:[String:Any])
    {
        let outputDict = self.removeNSNull(from:userDetail)
        UserDefaults.standard.set(outputDict, forKey: UserDefaults.KeysDefault.userInfo)
        
    }
    
    // MARK: - FetchUserInfoFromAppshareData -------------------------
    func fetchUserInfoFromAppshareData()
    {
        if let userDic = UserDefaults.standard.value(forKey:  UserDefaults.KeysDefault.userInfo) as? [String : Any]{
            UserDetail = UserModel.init(from: userDic)
        }
    }
    
    func removeNSNull(from dict: [String: Any]) -> [String: Any] {
        var mutableDict = dict
        let keysWithEmptString = dict.filter { $0.1 is NSNull }.map { $0.0 }
        for key in keysWithEmptString {
            mutableDict[key] = ""
            print(key)
        }
        return mutableDict
    }
    
    //MARK: - Sign Out
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.KeysDefault.userInfo)
        UserDetail = UserModel(from: [:])
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController)!
        let navController = UINavigationController(rootViewController: vc)
        navController.isNavigationBarHidden = true
        appDelegate.window?.rootViewController = navController
    }
    
}


var deviceToken: String? {
    get {
        return UserDefaults.standard.value(forKey: UserDefaults.KeysDefault.deviceToken) as? String ?? "abc"
    }
}



extension UserDefaults{
    enum KeysDefault {
        //user Info
        static let userInfo = "userInfo"
        static let strVenderId = "udid"
        static let deviceToken = "device_token"
        static let contentURLs = "content"
        static let kAuthToken = "authToken"
        static  let kUserId = "userId"
        static  let kCategoryID = "category_id"
    }
    
}
