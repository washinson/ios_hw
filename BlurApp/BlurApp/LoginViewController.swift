//
//  LoginViewController.swift
//  BlurApp
//
//  Created by alex on 27.01.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var backgroundImageView:UIImageView!
    
    let imageSet = ["cloud", "coffee", "food", "pmq", "temple"]
    
    var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Randomly pick an image
        let selectedImageIndex = Int(arc4random_uniform(5))
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }
}
