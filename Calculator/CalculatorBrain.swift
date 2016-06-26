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
        return pending != nil
    }
    
    var result: String {
        return formatDouble(accumulator)
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
        self.internalProgram = []
        self.variableValues = [String: Double]()
    }
    
    func flushPendingOperations() {
        self.pending = nil
        self.accumulator = 0.0
    }

    var description: String {
        var descriptionEnding = "..."
        if !isPartialResult {
            descriptionEnding = "="
        }
        return calculateDescription() + " " + descriptionEnding
    }
    
    private func changeInOperatorsPrecedence(lastOperator: String?, newOperator: String) -> Bool {
        if (lastOperator == "+" && newOperator == "-") || (lastOperator == "-" && newOperator == "+"){
            return false
        } else if (lastOperator == "✕" && newOperator == "÷") || (lastOperator == "÷" && newOperator == "✕") {
            return false
        }
        return (lastOperator ?? newOperator) != newOperator
    }
    
    private func calculateDescription() -> String {
        var isFinal = false
        var description = ""
        var lastOperator: String?
        
        for op in internalProgram {
            if let number = op as? Double {
                if isFinal { description = "" }
                if !description.isEmpty { description += " " }
                description += formatDouble(number)
                isFinal = false
            } else if let symbol = op as? String {
                if let operation = operations[symbol] {
                    switch operation {
                    case .Constant:
                        description += " " + symbol
                        isFinal = false
                    case .Variable:
                        if isFinal { description = "" }
                        description += " " + symbol
                        isFinal = false
                    case .Unary(_, let format):
                        if !isFinal {
                            var tmpArray = description.componentsSeparatedByString(" ")
                            tmpArray[tmpArray.count - 1] = format(tmpArray[tmpArray.count - 1])
                            description = tmpArray.joinWithSeparator(" ")
                        } else {
                            description = format(description)
                        }
                    case .Binary:
                        if changeInOperatorsPrecedence(lastOperator, newOperator: symbol) {
                            description = "(\(description)) " + symbol
                        } else {
                            description += " " + symbol
                        }
                        isFinal = false
                        lastOperator = symbol
                    case .Equal:
                        isFinal = true
                    }
                }
            }
        }
        return description
    }
    
    func performOperation(mathematicalSymbol: String) {
        internalProgram.append(mathematicalSymbol)
        
        if let operation = operations[mathematicalSymbol] {
            switch operation {
            case .Constant(let associatedValue):
                accumulator = associatedValue
            case .Unary(let function, _):
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
    
    typealias PropertyList = AnyObject
    private var internalProgram = [PropertyList]()
    
    private enum Operation {
        case Constant(Double)
        case Unary((Double) -> Double, (String) -> String)
        case Binary((Double, Double) -> Double)
        case Equal
        case Variable(String)
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),

        "cos": Operation.Unary(cos, { "cos(\($0))" }),
        "sin": Operation.Unary(sin, { "sin(\($0))" }),
        "tan": Operation.Unary(tan, { "tan(\($0))" }),
        "sinh": Operation.Unary(sinh, { "sinh(\($0))" }),
        "cosh": Operation.Unary(cosh, { "cosh(\($0))" }),
        "tanh": Operation.Unary(tanh, { "tanh(\($0))" }),
        
        "ln": Operation.Unary(log, { "log(\($0))" }),
        "log₁₀": Operation.Unary(log10, { "log₁₀(\($0))" }),
        "1/⒳": Operation.Unary({ 1/$0 }, { "1/(\($0))" }),
        "⒳²": Operation.Unary({ pow($0, 2) }, { "(\($0))^2" }),
        "⒳³": Operation.Unary({ pow($0, 3) }, { "(\($0))^3" }),
        "√": Operation.Unary(sqrt, { "√(\($0))" }),
        "∛": Operation.Unary(cbrt, { "∛(\($0))" }),
        "±": Operation.Unary({ -$0 }, { "-(\($0))" }),
        
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


















