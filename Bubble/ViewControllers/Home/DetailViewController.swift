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
    
    var obj:DashboardModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        self.lblMeterCount.text = obj.average_rating
        
//        let distance = self.calculateDistanceToDestination(latitudeString: obj.lat ?? "", longitudeString: obj.lng ?? "")
//        cell.lblDistance.text = distance
    }
    

    @IBAction func btnOnBack(_ sender: Any) {
        onBackPressed()
    }
    
    @IBAction func btnOnMenu(_ sender: Any) {
        
    }
    

}
