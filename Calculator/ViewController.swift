//
//  ViewController.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-21.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func pressDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let currentValueOnDisplay = display.text!
            display.text = currentValueOnDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func pressOperator(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        descriptionDisplay.text = brain.publicDescription
        displayValue = brain.result
    }
    
    @IBAction func touchPoint(sender: UIButton) {
        if( display.text?.rangeOfString(".") == nil ){
            display.text! += "."
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clearDisplay(sender: UIButton) {
        display.text = "0"
        descriptionDisplay.text = ""
        userIsInTheMiddleOfTyping = false
        brain.flushPendingOperations()
    }
}

