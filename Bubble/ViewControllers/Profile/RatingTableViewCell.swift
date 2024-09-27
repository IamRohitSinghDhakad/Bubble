//
//  RatingTableViewCell.swift
//  Bubble
//
//  Created by Rohit SIngh Dhakad on 27/09/24.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var vwRating: FloatRatingView!
    @IBOutlet weak var lblRatinGComment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
