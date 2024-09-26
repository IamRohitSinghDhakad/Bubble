//
//  EditProfileViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 25/09/24.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var imgVwUser: UIImageView!
    @IBOutlet weak var txtVwBio: RDTextView!
    @IBOutlet weak var imgVwMale: UIImageView!
    @IBOutlet weak var imgVwFemale: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    @IBAction func btnOnGoBack(_ sender: Any) {
        self.onBackPressed()
    }
    
    @IBAction func btnOnMale(_ sender: Any) {
    }
    
    @IBAction func btnOnFemale(_ sender: Any) {
    }
    @IBAction func btnOpenImage(_ sender: Any) {
        MediaPicker.shared.pickMedia(from: self) { image in
            self.imgVwUser.image = image
        }
    }
    
    @IBAction func btnOnSubmit(_ sender: Any) {
        
    }
    
    
}
