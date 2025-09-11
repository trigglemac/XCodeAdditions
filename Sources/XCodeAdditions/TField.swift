//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

public struct Tfield: View {
    @Binding var text: String
    var label: String
    var required: Bool
    var type: TType
    @State private var deletedCharacters: [Character] = []
    @State var inputState: InputState = .idle
    @State private var prompt: String
    @FocusState var isFocused: Bool
    private let debugging: Bool = true

    public init(
        _ text: Binding<String>, type: TType = .phrase, required: Bool = false,
        label: String = ""
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        _prompt = State(initialValue: type.template)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                TextFieldView
                floatingLabel
                makeStateMessage()
            }
            makeErrorMessage()
        }
        .frame(height: mainFrameHeight)
        .animation(.spring(duration: 0.2), value: inputState)
        .onChange(of: isFocused) { _, _ in updateState() }
        .onChange(of: text) { old, newInput in
            updateState()
        }
        .onAppear(perform: formatInputText)
       
            

    }
    private func formatInputText() {  //this will handle any input filtering (like only numbers, or only 3 digits)
        text = type.reconstruct(type.filter(text), &prompt)
        print("text: \(text), TFPrompt: \(prompt)")
    }
    private func updateState() {
        var errorMessage: String = ""
        if isFocused {
            formatInputText()
            if type.validateLive(text, &errorMessage) {
                inputState = .focused(.valid)
            } else {
                inputState = .focused(.invalid(errorMessage))
            }
        } else {
            if text.isEmpty {
                formatInputText()
                if required {  // required and empty
                    inputState = .inactive(.invalid("Required Entry"))
                } else {  //optional and empty
                    inputState = .idle
                }
            } else {
                prompt = ""
                if type.validateResult(text, &errorMessage) {
                    inputState = .inactive(.valid)
                } else {
                    inputState = .inactive(.invalid(errorMessage))
                }
            }
        }
    }
}
#Preview {
    TFieldExamples()
}

extension Tfield {
    var TextFieldView: some View {
        TextField("", text: $text)
            .font(.system(.body, design: .monospaced))
        #if canImport(UIKit)
            .keyboardType(type.keyboardType)
        #endif
            .autocorrectionDisabled(true)
            .focused($isFocused)
            .overlay(alignment: .leading) {
                Text("\(prompt)")
                    .font(.system(.body, design: .monospaced))
                    .frame( alignment: .trailing)
                    .offset(x: 2)
                    .foregroundStyle(.gray)
                    .onTapGesture {
                        isFocused = true

                    }
            }
            .padding(.horizontal)
            .frame(height: 55)
            .background(
                Capsule().stroke(
                    inputState.tintColor, lineWidth: isFocused ? 2 : 1))
    }
}  // TextFieldView

extension Tfield {
    var floatingLabel: some View {
        Text(getLabel())
            .padding(.horizontal, 5)
            .background(.background)
            .foregroundStyle(inputState.tintColor)
            .padding(.leading)
            .offset(y: labelOffset)
            .scaleEffect(labelScale)
            .onTapGesture {
                isFocused = true
            }
    }
    private func getLabel() -> String {
        if label.isEmpty {
            return type.description
        } else {
            return label
        }
    }
}  // floatingLabel

extension Tfield {
    @ViewBuilder
    func makeErrorMessage() -> some View {
        Group {
            if case let .invalid(message) = inputState.validity {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading)
                    .offset(y: errorOffset)
                    .padding(.top, 4)
            }
        }
    }
}  // makeErrorMessage

extension Tfield {
    @ViewBuilder
    func makeStateMessage() -> some View {
        Group {
            if debugging {
                Text("\(type) / \(inputState.description)")
                    .foregroundStyle(inputState.debugDescriptionColor)
                    .bold(required)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading)
                    .offset(y: debugOffset)
                    .offset(x: -10)
                    .padding(.top, 4)
            } else {
                EmptyView()
            }
        }
    }
}  // makeStateMessage (if debugging)


extension Tfield {

    var labelOffset: CGFloat {
        switch inputState {
        case .idle where text.isEmpty && prompt.isEmpty: return 0
        default: return -32
        }
    }

    var labelScale: CGFloat {
        switch inputState {
        case .idle where text.isEmpty && prompt.isEmpty: return 1
        default: return 0.85
        }
    }

    var errorOffset: CGFloat {
        switch inputState {
        case .idle where text.isEmpty: return 0
        default: return -10
        }
    }

    var debugOffset: CGFloat {
        switch inputState {
        case .idle where text.isEmpty && prompt.isEmpty: return 0
        case .inactive(.valid) where text.isEmpty && prompt.isEmpty: return 0
        case .inactive(.invalid) where text.isEmpty && prompt.isEmpty: return 0

        default: return -36
        }
    }
    var mainFrameHeight: CGFloat {
        var height: CGFloat = 55
        if hasError {
            height += 30
        }
        if debugging {
            height += 10
        }
        return height
    }

    var hasError: Bool {  //Computed Boolean.  If an error is detected, this will be true
        switch inputState {
        case .focused(.invalid): return true
        case .inactive(.invalid): return true
        default: return false
        }
    }
}  // offset calculations for floating elements
