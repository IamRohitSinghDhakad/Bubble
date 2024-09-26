//
//  WebViewController.swift
//  Bubble
//
//  Created by Dhakad, Rohit Singh (Cognizant) on 24/09/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var btnOnBack: UIButton!
    @IBOutlet weak var webVw: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func btnOnBack(_ sender: Any) {
        onBackPressed()
    }
    

}
