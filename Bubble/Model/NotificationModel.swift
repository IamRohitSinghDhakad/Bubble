//
//  NotificationModel.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 26/09/24.
//

import UIKit

class NotificationModel: NSObject {

    var action_id : String?
    var comment : String?
    var message : String?
    var notification_type : String?
    var user_id : String?
    
    
    
    init(from dictionary: [String: Any]) {
        super.init()
        
        if let value = dictionary["comment"] as? String {
            comment = value
        }
        
        if let value = dictionary["message"] as? String {
            message = value
        }
        
        if let value = dictionary["action_id"] as? String {
            action_id = value
        }else if let value = dictionary["action_id"] as? Int {
            action_id = "\(value)"
        }
        
        if let value = dictionary["user_id"] as? String {
            user_id = value
        }else if let value = dictionary["user_id"] as? Int {
            user_id = "\(value)"
        }
    }
}
