//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-21.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import Foundation

class CalculatorBrain {

    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var result: String {
        get {
            return formatDouble(accumulator)
        }
    }
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            flushPendingOperations()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let number = op as? Double {
                        setOperand(number)
                    } else if let symbol = op as? String {
                        performOperation(symbol)
                    }
                }
            }
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        
        if isPartialResult {
            descriptionArray.append(formatDouble(accumulator))
        } else {
            descriptionArray = [formatDouble(accumulator)]
        }
    }
    
    func flushPendingOperations() {
        self.pending = nil
        self.accumulator = 0.0
        self.descriptionArray = []
    }

    var description: String {
        get {
            var descriptionEnding = "..."
            if !isPartialResult {
                descriptionEnding = "="
            }
            return descriptionArray.joinWithSeparator(" ") + " " + descriptionEnding
        }
    }
    
    func performOperation(mathematicalSymbol: String) {
        internalProgram.append(mathematicalSymbol)
        
        if let operation = operations[mathematicalSymbol] {
            switch operation {
                
            case .Constant(let associatedValue):
                accumulator = associatedValue
                if isPartialResult {
                    descriptionArray.append(mathematicalSymbol)
                } else {
                    descriptionArray = [mathematicalSymbol]
                }
                
            case .Unary(let function):
                if isPartialResult {
                    let lastElement = descriptionArray.popLast()!
                    descriptionArray.append("\(mathematicalSymbol)(\(lastElement))")
                } else {
                    descriptionArray[0] = "\(mathematicalSymbol)(\(descriptionArray.first!)"
                    descriptionArray[descriptionArray.count-1] = "\(descriptionArray.last!))"
                }
                accumulator = function(accumulator)
                
            case .Binary(let function):
                descriptionArray.append(mathematicalSymbol)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equal:
                executePendingBinaryOperation()
            }
        }
    }
    
    // Private methods and variables
    
    private var accumulator = 0.0
    
    private var pending: PendingBinaryOperationInfo?
    
    private var descriptionArray: [String] = []
    
    typealias PropertyList = AnyObject
    private var internalProgram = [PropertyList]()
    
    private enum Operation {
        case Constant( Double )
        case Unary( (Double) -> Double )
        case Binary( (Double, Double) -> Double )
        case Equal
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),

        "cos": Operation.Unary(cos),
        "sin": Operation.Unary(sin),
        "tan": Operation.Unary(tan),
        "sinh": Operation.Unary(sinh),
        "cosh": Operation.Unary(cosh),
        "tanh": Operation.Unary(tanh),
        
        "ln": Operation.Unary(log),
        "log₁₀": Operation.Unary(log10),
        "1/⒳": Operation.Unary({ 1/$0 }),
        "⒳²": Operation.Unary({ pow($0, 2) }),
        "⒳³": Operation.Unary({ pow($0, 3) }),
        "√": Operation.Unary(sqrt),
        "∛": Operation.Unary(cbrt),
        "±": Operation.Unary({ -$0 }),
        
        "✕": Operation.Binary({ $0 * $1 }),
        "+": Operation.Binary({ $0 + $1 }),
        "-": Operation.Binary({ $0 - $1 }),
        "÷": Operation.Binary({ $0 / $1 }),
        
        "=": Operation.Equal,
    ]

    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func formatDouble(number: Double) -> String {
        let formater = NSNumberFormatter()
        formater.minimumFractionDigits = 0
        formater.maximumFractionDigits = 6
        formater.numberStyle = .DecimalStyle
        return formater.stringFromNumber(number)!
    }
}


















