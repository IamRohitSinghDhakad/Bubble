//
//  CommentsTableViewCell.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 20/09/24.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTimeAgo: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
