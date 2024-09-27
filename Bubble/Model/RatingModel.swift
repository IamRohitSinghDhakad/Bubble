//
//  RatingModel.swift
//  Bubble
//
//  Created by Rohit SIngh Dhakad on 28/09/24.
//

import UIKit

class RatingModel: NSObject {
    
    var name : String?
    var review : String?
    var rating : String?
    var user_image : String?
    var user_id : String?
    
    
    
    init(from dictionary: [String: Any]) {
        super.init()
        
        if let value = dictionary["name"] as? String {
            name = value
        }
        
        if let value = dictionary["review"] as? String {
            review = value
        }
        
        if let value = dictionary["user_id"] as? String {
            user_id = value
        }else if let value = dictionary["user_id"] as? Int {
            user_id = "\(value)"
        }
        
        if let value = dictionary["rating"] as? String {
            rating = value
        }else if let value = dictionary["rating"] as? Int {
            rating = "\(value)"
        }
        
      
    }
}
