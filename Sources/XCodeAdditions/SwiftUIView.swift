//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/14/25.
//

// Subtle warm gradient
import SwiftUI


func validGradient( isFocused: Bool) -> LinearGradient {
    let baseOpacity: Double = isFocused ? 0.08 : 0.04
    
    return LinearGradient(
        gradient: Gradient(colors: [
            Color.green.opacity(baseOpacity * 0.5),
            Color.green.opacity(baseOpacity)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

func invalidGradient( isFocused: Bool) -> LinearGradient {
    let baseOpacity: Double = isFocused ? 0.08 : 0.04
    
    return LinearGradient(
        gradient: Gradient(colors: [
            Color.red.opacity(baseOpacity * 0.5),
            Color.red.opacity(baseOpacity)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

func defaultGradient( isFocused: Bool) -> LinearGradient {
    let baseOpacity: Double = isFocused ? 0.08 : 0.04
    
    return LinearGradient(
        gradient: Gradient(colors: [
            Color.blue.opacity(baseOpacity * 0.5),
            Color.blue.opacity(baseOpacity)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

