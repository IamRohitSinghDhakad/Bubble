//
//  CustomUIView.swift
//  TechnicalWorld
//
//  Created by Paras on 11/04/21.
//

import Foundation
//
//  UIView-Extension.swift
//

import UIKit

@IBDesignable
extension UIView {
     // Shadow
     @IBInspectable var shadow: Bool {
          get {
               return layer.shadowOpacity > 0.0
          }
          set {
               if newValue == true {
                    self.addShadow()
               }
          }
     }

     fileprivate func addShadow(shadowColor: CGColor = UIColor.black.cgColor, shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0), shadowOpacity: Float = 0.1, shadowRadius: CGFloat = 4.0) {
          let layer = self.layer
          layer.masksToBounds = false

          layer.shadowColor = shadowColor
          layer.shadowOffset = shadowOffset
          layer.shadowRadius = shadowRadius
          layer.shadowOpacity = shadowOpacity
          layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath

          let backgroundColor = self.backgroundColor?.cgColor
          self.backgroundColor = nil
          layer.backgroundColor =  backgroundColor
     }



     // Corner radius
     @IBInspectable var circle: Bool {
          get {
               return layer.cornerRadius == self.bounds.width*0.5
          }
          set {
               if newValue == true {
                    self.cornerRadius = self.bounds.width*0.5
               }
          }
     }

     @IBInspectable var cornerRadius: CGFloat {
          get {
               return self.layer.cornerRadius
          }

          set {
               self.layer.cornerRadius = newValue
          }
     }


     // Borders
     // Border width
     @IBInspectable
     public var borderWidth: CGFloat {
          set {
               layer.borderWidth = newValue
          }

          get {
               return layer.borderWidth
          }
     }

     // Border color
     @IBInspectable
     public var borderColor: UIColor? {
          set {
               layer.borderColor = newValue?.cgColor
          }

          get {
               if let borderColor = layer.borderColor {
                    return UIColor(cgColor: borderColor)
               }
               return nil
          }
     }
}
