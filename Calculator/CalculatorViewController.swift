//
//  ViewController.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-21.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

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
    
    private var program: AnyObject?
    
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
        
        saveProgram()
        descriptionDisplay.text = brain.description
        display.text = brain.result
    }
    
    @IBAction func touchPoint(sender: UIButton) {
        if( display.text?.rangeOfString(".") == nil ){
            display.text! += "."
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clearDisplay(sender: UIButton) {
        display.text = "0"
        descriptionDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        program = []
        brain.clear()
    }
    
    @IBAction func touchDelete(sender: AnyObject) {
        if let newText = display.text?.characters.dropLast() {
            if newText.count > 0 {
                display.text = String(newText)
            } else {
                userIsInTheMiddleOfTyping = false
                display.text = "0"
            }
        }
    }
    
    func saveProgram() {
        program = brain.program
    }
    
    func restoreProgram() {
        brain.program = program!
        display.text = brain.result
        descriptionDisplay.text = brain.description
    }
    
    // ->M button
    @IBAction func setVariableValue() {
        brain.variableValues["M"] = displayValue
        restoreProgram()
        userIsInTheMiddleOfTyping = false
    }
    
    // M button
    @IBAction func insertVariable() {
        brain.setOperand("M")
        userIsInTheMiddleOfTyping = false
        saveProgram()
        descriptionDisplay.text = brain.description
        display.text = brain.result
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Graph":
                break
            default:
                break
            }
        }
    }
}








