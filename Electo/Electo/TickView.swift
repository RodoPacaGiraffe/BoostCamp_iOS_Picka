//
//  TickView.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 23..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class TickView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        print(self.center)
        let topPoint: CGPoint = CGPoint(x: self.center.x, y: self.center.y - 10)
        let bottomPoint: CGPoint = CGPoint(x: self.center.x, y: self.center.y + 10)
        
        addLine(fromPoint: topPoint, toPoint: bottomPoint)
        self.layoutIfNeeded()
    }
    
    private func addLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.darkGray.cgColor
        line.lineWidth = 1.5
        line.lineJoin = kCALineJoinRound
        
        self.layer.addSublayer(line)
    }
}
