//
//  GraphViewController.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-30.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var functionToGraph: ((Double) -> Double)? = { sin($0) }

    @IBOutlet private var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(
                UIPinchGestureRecognizer(
                    target: graphView,
                    action: #selector(GraphView.handlePinch(_:))
                )
            )
            
            let doubleTapReconizer = UITapGestureRecognizer(
                target: graphView,
                action: #selector(GraphView.handleTap(_:))
            )
            doubleTapReconizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapReconizer)
            
            let panRecognizer = UIPanGestureRecognizer(
                target: graphView,
                action: #selector(GraphView.handlePan(_:)
                )
            )
            graphView.addGestureRecognizer(panRecognizer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
