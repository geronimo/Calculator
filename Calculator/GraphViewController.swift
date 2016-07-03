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

    @IBOutlet private var graphView: GraphView!
    
    override func viewDidLoad() {
        //graphFunction()
        super.viewDidLoad()
    }

    // MARK: - Navigation

}
