//
//  GraphView.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-30.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

class GraphView: UIView {

    private var axesDrawer = AxesDrawer()
    
    override func drawRect(rect: CGRect) {
        let origin = CGPoint(x: bounds.midX, y: bounds.midY)
        axesDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: 30)
    }
}
