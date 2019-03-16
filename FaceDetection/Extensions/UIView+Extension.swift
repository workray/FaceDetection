//
//  UIViewExtension.swift
//  FaceDetection
//
//  Created by Mobdev125 on 3/16/19.
//  Copyright © 2019 Mobdev125. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
}
