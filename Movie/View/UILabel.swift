//
//  UILabel.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/20/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit

extension UILabel {
    
    //This variable calculates the height of a label based on the lines it has
    var optimalHeight : CGFloat {
        get
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.font = self.font
            label.text = self.text
            label.sizeToFit()
            return label.frame.height
        }
        
    }
}
