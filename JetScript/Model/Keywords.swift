//
//  Keywords.swift
//  JetScript
//
//  Created by Kirlos Yousef on 22/12/2020.
//

import Foundation
import SwiftUI

class Keywords {
    enum all: String , CaseIterable{
        case `let` = "let "
        case `var` = "var "
        case `func` = "func "
        case `for`
        case `print`
        case `import` = "import "
        case `Enum`
        case `public` = "public "
        case `private` = "private "
        case `class` = "class "
        case `if` = "if "
        case `switch`
        case `case`
        case `return` = "return "
        case `default`
    }
    
    func keywordColor(_ word: all) -> NSColor{
        switch word {
        case .let:
            return .systemPink
        case .var:
            return .systemPink
        case .func:
            return .systemOrange
        case .for:
            return .systemGreen
        case .print:
            return .systemIndigo
        case .import:
            return .systemPink
        case .Enum:
            return .systemPink
        case .public:
            return .systemPink
        case .private:
            return .systemPink
        case .class:
            return .systemOrange
        case .if:
            return .systemOrange
        case .switch:
            return .systemOrange
        case .case:
            return .systemYellow
        case .return:
            return .systemPink
        case .default:
            return .white
        }
    }
}
