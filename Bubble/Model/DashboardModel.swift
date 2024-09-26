//
//  HomeModel.swift
//  GMS
//
//  Created by Rohit SIngh Dhakad on 17/11/23.
//

import UIKit

class DashboardModel: NSObject {
    
    var address : String?
    var average_rating : String?
    var blue_tick: String?
    var blue_tick_status: String?
    var datetime : String?
    var strDescription : String?
    var favourite : String?
    var voted : String?
    var user_name : String?
    var user_image : String?
    var id : String?
    var total_votes : String?
    var total_comment : String?
    var post_id : String?
    var lng : String?
    var lat : String?
    var arrHasTag = [String]()
    
    
    
    init(from dictionary: [String: Any]) {
        super.init()
        
        if let value = dictionary["user_name"] as? String {
            user_name = value
        }
        
        if let value = dictionary["user_image"] as? String {
            user_image = value
        }
        
        if let value = dictionary["entrydt"] as? String {
            datetime = value
        }
        
        if let value = dictionary["address"] as? String {
            address = value
        }
        
        if let value = dictionary["description"] as? String {
            strDescription = value
        }
        
        if let value = dictionary["blue_tick_status"] as? String {
            blue_tick_status = value
        }
        
        if let value = dictionary["post_id"] as? String {
            post_id = value
        }else if let value = dictionary["post_id"] as? Int {
            post_id = "\(value)"
        }
        
        if let value = dictionary["user_id"] as? String {
            id = value
        }else if let value = dictionary["user_id"] as? Int {
            id = "\(value)"
        }
        
        if let value = dictionary["lng"] as? String {
            lng = value
        }else if let value = dictionary["lng"] as? Int {
            lng = "\(value)"
        }
        
        if let value = dictionary["lat"] as? String {
            lat = value
        }else if let value = dictionary["lat"] as? Int {
            lat = "\(value)"
        }
        
        
        if let value = dictionary["total_comment"] as? String {
            total_comment = value
        }else if let value = dictionary["total_comment"] as? Int {
            total_comment = "\(value)"
        }
        
        if let value = dictionary["total_votes"] as? String {
            total_votes = value
        }else if let value = dictionary["total_votes"] as? Int {
            total_votes = "\(value)"
        }
        
        if let value = dictionary["average_rating"] as? String {
            average_rating = value
        }else if let value = dictionary["average_rating"] as? Int {
            average_rating = "\(value)"
        }
        
        if let value = dictionary["voted"] as? String {
            voted = value
        }else if let value = dictionary["voted"] as? Int {
            voted = "\(value)"
        }
        
        if let value = dictionary["favourite"] as? String {
            favourite = value
        }else if let value = dictionary["favourite"] as? Int {
            favourite = "\(value)"
        }
        
        if let value = dictionary["blue_tick"] as? String {
            blue_tick = value
        }else if let value = dictionary["blue_tick"] as? Int {
            blue_tick = "\(value)"
        }
        
        
        if let value = dictionary["hashtag"] as? [String] {
            arrHasTag = value
        }
      
        
        //============== XXX ===============//
    }
    
}



class CommentsModel: NSObject {
    
    var comment : String?
    var time_ago : String?
    var user_image : String?
    var user_name : String?
    
    var id : String?
    var user_id : String?
    
    init(from dictionary: [String: Any]) {
        super.init()
        
        if let value = dictionary["comment"] as? String {
            comment = value
        }
        
        if let value = dictionary["time_ago"] as? String {
            time_ago = value
        }
        
        if let value = dictionary["user_image"] as? String {
            user_image = value
        }
        
        if let value = dictionary["user_name"] as? String {
            user_name = value
        }
        
        if let value = dictionary["id"] as? String {
            id = value
        }else if let value = dictionary["id"] as? Int {
            id = "\(value)"
        }
        
        if let value = dictionary["user_id"] as? String {
            user_id = value
        }else if let value = dictionary["user_id"] as? Int {
            user_id = "\(value)"
        }
    }
    
}

/*
 comment = hii;
 entrydt = "2024-09-13 23:20:17";
 id = 74;
 "time_ago" = "7 days ago";
 "user_id" = 38;
 "user_image" = "https://ambitious.in.net/Shubham/bubble/uploads/user/17253589384932.png";
 "user_name" = Shubham;
 */
