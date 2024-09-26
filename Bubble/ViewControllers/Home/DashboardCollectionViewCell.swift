//
//  DashboardCollectionViewCell.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 17/09/24.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgvwBlueTick: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var lblHasTag: UILabel!
    @IBOutlet weak var btnOpenMenu: UIButton!
    @IBOutlet weak var lblMsgCount: UILabel!
    @IBOutlet weak var lblMeterCount: UILabel!
    @IBOutlet weak var imgVwFav: UIImageView!
    @IBOutlet weak var btnOnMsg: UIButton!
    @IBOutlet weak var btnMeter: UIButton!
    @IBOutlet weak var btnOnFav: UIButton!
    @IBOutlet weak var btnOnShare: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
