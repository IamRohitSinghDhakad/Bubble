//
//  CustomUITextField.swift
//  MizanEstateAgents
//
//  Created by Rohit Singh Dhakad on 09/04/23.
//

import Foundation
import UIKit

@IBDesignable
@objc(CustomTextField)
class CustomTextField: UITextField {

    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            let placeholderText = self.placeholder ?? ""
            let attributes = [NSAttributedString.Key.foregroundColor: placeholderColor]
            self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.updatePlaceholderColor()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.updatePlaceholderColor()
    }

    private func updatePlaceholderColor() {
        let placeholderText = self.placeholder ?? ""
        let attributes = [NSAttributedString.Key.foregroundColor: placeholderColor]
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }

}

extension UIResponder {
    @objc class func overrideUserInterfaceStyle() {}
}

