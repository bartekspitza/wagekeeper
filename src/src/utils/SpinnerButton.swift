//
//  SpinnerButton.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-22.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import UIKit

class SpinnerButton: UIView {
    let loadingIndicator = UIActivityIndicatorView()
    private var cornerRadius: CGFloat = 0
    
    var button: UIButton!
    var title: String!
    var FBLogo: UIImageView?
    
    func addFBLogo() {
        let image = UIImage(named: "facebook")
        
        FBLogo = UIImageView(image: image)
        FBLogo!.setImageColor(color: UIColor.white)
        FBLogo!.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        FBLogo!.center = CGPoint(x: 20, y: self.frame.height/2)
        
        self.addSubview(FBLogo!)
    }
    
    init(frame: CGRect, spinnerColor: UIColor) {
        super.init(frame: frame)
        button = UIButton(type: .system)
        button.frame = frame
        button.center = CGPoint(x: frame.width/2, y: frame.height/2)
        self.addSubview(button)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = spinnerColor
        loadingIndicator.center = CGPoint(x: frame.width/2, y: frame.height/2)
        loadingIndicator.layer.zPosition = 10
        self.addSubview(loadingIndicator)
    }
    
    func setCornerRadius(radius: CGFloat) {
        self.cornerRadius = radius
        self.button.layer.cornerRadius = radius
    }
    
    func setTitle(title: String) {
        self.title = title
        self.button.setTitle(title, for: .normal)
    }
    
    func stopAnimating(newTitle: String?) {
        let new = newTitle == nil ? self.title : newTitle!
        self.loadingIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.button.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
            self.button.layer.cornerRadius = self.cornerRadius
            self.button.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        }) { (true) in
            
        }
        UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.button.setTitle(new, for: .normal)
        }, completion: nil)
        
        if self.FBLogo != nil {
            UIView.animate(withDuration: 0.1) {
                self.FBLogo?.layer.opacity = 1
            }
        }
    }
    
    func startAnimating() {
        let size = min(self.frame.width, self.frame.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.button.frame.size = CGSize(width: size, height: size)
            self.button.layer.cornerRadius = size/2
            self.button.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        }) { (true) in
            
        }
        UIView.transition(with: self.button, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.button.setTitle("", for: .normal)
        }, completion: { (true) in
            self.loadingIndicator.startAnimating()
        })
        if self.FBLogo != nil {
            UIView.animate(withDuration: 0.1) {
                self.FBLogo?.layer.opacity = 0
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
