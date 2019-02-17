//
//  Methods.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-16.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

func addButtons(bar: UIToolbar, withUpAndDown: Bool, color: UIColor) -> [UIBarButtonItem] {
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    doneButton.tintColor = .black
    
    var downBtn = UIBarButtonItem()
    var upBtn = UIBarButtonItem()
    
    
    if withUpAndDown {
        let imageDown = UIImage(named: "downBtn")
        let imageUp = UIImage(named: "upBtn")
        let size = 45
        
        
        downBtn = UIBarButtonItem(image: imageDown?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: nil, action: nil)
        upBtn = UIBarButtonItem(image: imageUp?.imageResize(sizeChange: CGSize(width: size, height: size)), style: UIBarButtonItem.Style.done, target: nil, action: nil)
        
        upBtn.tintColor = .black
        downBtn.tintColor = .black
        bar.setItems([upBtn, downBtn, flexSpace, doneButton], animated: false)
    } else {
        bar.setItems([flexSpace, doneButton], animated: false)
    }
    
    bar.sizeToFit()
    
    return [doneButton, upBtn, downBtn]
}
