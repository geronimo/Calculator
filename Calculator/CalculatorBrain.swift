//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Geronimo De Abreu on 2016-06-21.
//  Copyright © 2016 Geronimo De Abreu. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
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
        "-": Operation.Binary({ $0 + $1 }),
        "÷": Operation.Binary({ $0 / $1 }),
        
        "=": Operation.Equal,
    ]
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    func flushPendingOperations() {
        self.pending = nil
        self.accumulator = 0.0
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    func performOperation(mathematicalSymbol: String) {
        if let operation = operations[mathematicalSymbol] {
            switch operation {
            case .Constant(let associatedValue):
                accumulator = associatedValue
            case .Unary(let function):
                accumulator = function(accumulator)
            case .Binary(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equal:
                executePendingBinaryOperation()
            }
        }
    }
    
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
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    private enum Operation {
        case Constant( Double )
        case Unary( (Double) -> Double )
        case Binary( (Double, Double) -> Double )
        case Equal
    }
}
