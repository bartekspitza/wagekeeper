//
//  Extensions.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-29.
//  Copyright © 2017 Bartek . All rights reserved.
//

import Foundation
import UIKit



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIToolbar {
    func addButtons(withUpAndDown: Bool, color: UIColor) -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        doneButton.tintColor = .black
        
        var downBtn = UIBarButtonItem()
        var upBtn = UIBarButtonItem()
        
        
        if withUpAndDown {
            let imageDown = UIImage(named: "downBtn")
            let imageUp = UIImage(named: "upBtn")
            let size = 45
            
            
            downBtn = UIBarButtonItem(image: imageDown?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: nil)
            upBtn = UIBarButtonItem(image: imageUp?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: self, action: nil)
            
            upBtn.tintColor = .black
            downBtn.tintColor = .black
            self.setItems([upBtn, downBtn, flexSpace, doneButton], animated: false)
        } else {
            self.setItems([flexSpace, doneButton], animated: false)
        }
        
        self.sizeToFit()
        
        return [doneButton, upBtn, downBtn]
    }
}

extension UITextField {
    
    func addBottomBorder(color: UIColor, width: CGFloat) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: width)
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(bottomLine)
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension UITableView {
    func deselectAllRows() {
        if let index = self.indexPathsForSelectedRows {
            for i in index {
                self.deselectRow(at: i, animated: true)
            }
        }
    }
}

extension UIViewController {
    
    func hideNavBarSeparator() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    
    func endY() -> CGFloat {
        return self.frame.origin.y + self.frame.height
    }
    
    func endX() -> CGFloat {
        return self.frame.origin.x + self.frame.width
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        shadowLayer.fillColor = color.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 3
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension String {
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func toDateTime() -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        return dateFormatter.date(from: self)!
    }
}

// Image resizing
extension UIImage {
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}

// String to floatvalue
extension String {
    var floatValue: Float {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.floatValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
}

// Button animation

extension UIImageView {
    
    func shake(direction: String, swings: Float) {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = swings
        shake.autoreverses = true
        
        var fromPoint: CGPoint!
        var fromValue: NSValue!
        var toPoint: CGPoint!
        var toValue: NSValue!
        
        
        if direction == "vertical" {
            fromPoint = CGPoint(x: center.x, y: center.y)
            fromValue = NSValue(cgPoint: fromPoint)
            
            toPoint = CGPoint(x: center.x, y: center.y+5)
            toValue = NSValue(cgPoint: toPoint)
        } else if direction == "horizontal" {
            fromPoint = CGPoint(x: center.x, y: center.y)
            fromValue = NSValue(cgPoint: fromPoint)
            
            toPoint = CGPoint(x: center.x+5, y: center.y)
            toValue = NSValue(cgPoint: toPoint)
        }
            
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}
