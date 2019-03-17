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
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        for laser in lasers {
            context.addLines(between: [laser.origin, laser.focus])
            
            context.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            context.setLineWidth(4.5)
            context.strokePath()
            
            context.addLines(between: [laser.origin, laser.focus])
            
            context.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8)
            context.setLineWidth(3.0)
            context.strokePath()
        }
        
        context.restoreGState()
    }
}
