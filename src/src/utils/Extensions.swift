//
//  Extensions.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-29.
//  Copyright © 2017 Bartek . All rights reserved.
//

import Foundation
import UIKit


func getShifts(fromCloud: Bool) {
    
    if fromCloud {
        // do something
    } else {
        print("Fetched data from local storage")
        LocalStorage.values = LocalStorage.getAllShifts()
        LocalStorage.organizedValues = Period.organizeShiftsIntoPeriods(ar: &LocalStorage.values)
        shifts = Period.convertShiftsFromCoreDataToModels(arr: LocalStorage.organizedValues)
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

extension UIButton {
    
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
