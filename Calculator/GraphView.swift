//
//  GraphView.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-30.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    @IBInspectable var scale: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var pointsPerUnit: CGFloat = 50
    
    var graphOrigin: CGPoint {
        get {
            return origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            origin = newValue
            setNeedsDisplay()
        }
    }
    
    var functionToGraph: ((Double)->Double)? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var origin: CGPoint?
    
    private var axesDrawer = AxesDrawer()
    private var functionDrawer = FunctionDrawer()
    
    func handlePinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed, .Ended:
            scale *= gesture.scale
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            graphOrigin = gesture.locationInView(self)
        default:
            break
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed, .Ended:
            let translation = gesture.translationInView(self)
            graphOrigin = CGPoint(x: graphOrigin.x + translation.x, y: graphOrigin.y + translation.y)
            gesture.setTranslation(CGPoint(x: 0, y: 0), inView: self)
        default:
            break
        }
    }
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(
            self.bounds,
            origin: graphOrigin,
            pointsPerUnit: pointsPerUnit * scale
        )
        
        if let function = functionToGraph {
            functionDrawer.graphFunction(
                self.bounds,
                origin: graphOrigin,
                functionToGraph: function,
                pointsPerUnit: pointsPerUnit * scale
            )
        }
    }
}
