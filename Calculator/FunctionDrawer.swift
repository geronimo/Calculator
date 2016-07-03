//
//  FunctionDrawer.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-07-01.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

class FunctionDrawer {
    
    var color = UIColor.redColor()
    
    func graphFunction(bounds: CGRect, functionToGraph: (Double)->Double, pointsPerUnit: CGFloat) {
        
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        
        let path = UIBezierPath()
        var x = CGFloat(0.0)
        var firstPoint = true
        
        while x <= bounds.width {
            
            let i = Double(x - bounds.midX) / Double(pointsPerUnit)
            let j = functionToGraph(i)
            //print(i, j)
            
            // Check that the number is valid
            if j != j {
                //print("NaN")
                x += 1
                firstPoint = true
                continue
            }
            
            let nextPoint = CGPoint(x: x, y: (CGFloat(-j) * CGFloat(pointsPerUnit)) + bounds.midY )
            
            // Check if the function is continuous between the last two points
            if !firstPoint && !isContinous(path.currentPoint, nextPoint: nextPoint) {
                firstPoint = true
            }
            
            if firstPoint {
                path.moveToPoint(nextPoint)
                firstPoint = false
            } else {
                path.addLineToPoint(nextPoint)
            }
            
            x += 1
        }
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    
    func isContinous(currentPoint: CGPoint, nextPoint: CGPoint) -> Bool {
        let slope = (nextPoint.y - currentPoint.y) / (nextPoint.x - currentPoint.x)
        return abs(slope) < 100
    }
    
    func transformPointFromBoundsToCartesian(point: CGPoint, bounds: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x + bounds.midX,
            y: point.y + bounds.midY
        )
    }
}