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
    }
    
    var variableValues: Dictionary<String, Double> = [String: Double]()
    
    func setOperand(variableName: String) {
        performOperation("M")
    }
    
    func clear() {
        self.pending = nil
        self.accumulator = 0
        self.descriptionArray = []
        self.internalProgram = []
        self.variableValues = [String: Double]()
    }
    
    func flushPendingOperations() {
        self.pending = nil
        self.accumulator = 0.0
    }

    var description: String {
        get {
            calculateDescription()
            var descriptionEnding = "..."
            if !isPartialResult {
                descriptionEnding = "="
            }
            return descriptionArray.joinWithSeparator(" ") + " " + descriptionEnding
        }
    }
    
    private func calculateDescription(){
        descriptionArray = []
        var isFinal = false
        
        for op in internalProgram {
            if let number = op as? Double {
                if isFinal { descriptionArray = [] }
                descriptionArray.append(formatDouble(number))
                isFinal = false
            } else if let symbol = op as? String {
                
                if let operation = operations[symbol] {
                    switch operation {
                    case .Constant:
                        descriptionArray.append(symbol)
                        isFinal = false
                    case .Variable:
                        if isFinal { descriptionArray = [] }
                        descriptionArray.append(symbol)
                        isFinal = false
                    case .Unary:
                        if !isFinal {
                            let lastElement = descriptionArray.popLast()!
                            descriptionArray.append("\(symbol)(\(lastElement))")
                        } else {
                            descriptionArray[0] = "\(symbol)(\(descriptionArray.first!)"
                            descriptionArray[descriptionArray.count-1] = "\(descriptionArray.last!))"
                        }
                    case .Binary:
                        descriptionArray.append(symbol)
                        isFinal = false
                    case .Equal:
                        isFinal = true
                    }
                }
            }
        }
    }
    
    func performOperation(mathematicalSymbol: String) {
        internalProgram.append(mathematicalSymbol)
        
        if let operation = operations[mathematicalSymbol] {
            switch operation {
            case .Constant(let associatedValue):
                accumulator = associatedValue
            case .Unary(let function):
                accumulator = function(accumulator)
            case .Binary(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Variable(let variableName):
                accumulator = variableValues[variableName] ?? 0
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
        case Constant(Double)
        case Unary((Double) -> Double)
        case Binary((Double, Double) -> Double)
        case Equal
        case Variable(String)
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
        
        "M": Operation.Variable("M")
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


















