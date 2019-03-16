//
//  LaserView.swift
//  FaceDetection
//
//  Created by Mobdev125 on 3/16/19.
//  Copyright © 2019 Mobdev125. All rights reserved.
//

import UIKit

struct Laser {
    var origin: CGPoint
    var focus: CGPoint
}

class LaserView: UIView {
    private var lasers: [Laser] = []
    
    func add(laser: Laser) {
        lasers.append(laser)
    }
    
    func clear() {
        lasers.removeAll()
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
    }
}
