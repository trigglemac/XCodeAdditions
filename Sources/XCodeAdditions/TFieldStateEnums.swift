//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

// The following enums are used for state, and are set by the textfield view TFView

// They are private to the view, and should not be modified or manhandled outside of the TField code itself
// More specifically, they are set initially, and then are modified by the updataState routine.

// Textfield state definition...
enum InputState: Equatable, CustomStringConvertible {
    case idle  //Textfield is either idle - initial state, waiting for interaction
    case focused(InputValidity)  //has focus, with either empty, valid or invalid entry
    case inactive(InputValidity)  //lost focus, with either empty, valid or invalid entry

    enum InputValidity: Equatable {
        case empty
        case valid
        case invalid(String)
    }
    
    var validity: InputValidity {
        switch self {
        case .idle: return .empty
        case .focused(let validity): return validity
        case .inactive(let validity): return validity
        }
    }
    
    var description: String {
        switch self {
        case .idle: return "idle"
        case .focused(let validity): return "focused(\(validity))"
        case .inactive(let validity): return "inactive(\(validity))"
        }
    }
}


// UI Properties driven by the above enum combinations...

extension InputState {
    var tintColor: Color {
        switch self {
        case .idle: return .secondary
        case let .focused(validity):
            switch validity {
            case .empty: return .blue
            case .valid: return .blue
            case .invalid: return .red
            }
        case let .inactive(validity):
            switch validity {
            case .empty: return .secondary
            case .valid: return .blue
            case .invalid: return .red
            }
        }
    }
    
    var debugDescriptionColor: Color {
        switch self {
        case .idle: return .gray
        case let .focused(validity):
            switch validity {
            case .empty: return .gray
            case .valid: return .blue
            case .invalid: return .red
            }
        case let .inactive(validity):
            switch validity {
            case .empty: return .gray
            case .valid: return .blue.opacity(0.5)
            case .invalid: return .red.opacity(0.5)
            }
        }
    }
}
