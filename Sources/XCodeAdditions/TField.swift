//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

public struct Tfield<T: TBType>: View {
    @Binding var text: String
    var label: String
    var required: Bool
    var type: T
    @State private var deletedCharacters: [Character] = []
    @State var inputState: InputState = .idle
    @State private var prompt: String
    @FocusState var isFocused: Bool
    @State private var contentPriority: Double = 1.0
    @State private var cachedMinWidth: CGFloat = 120
    private let debugging: Bool = true

    public init(
        _ text: Binding<String>, type: T, required: Bool = false,
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
                requiredIndicator
                floatingLabel
                makeStateMessage()
                makeErrorMessage()
            }
            
        }
        .frame(height: mainFrameHeight)
        .layoutPriority(contentPriority)
        .animation(.spring(duration: 0.2), value: inputState)
        .animation(.easeInOut(duration: 0.2), value: contentPriority)
        .onChange(of: isFocused) { _, _ in
            updateState()
            updateLayoutPriority()
        }
        .onChange(of: text) { old, newInput in
            updateState()
            updateLayoutPriority()
            updateMinWidth()
        }
        .onChange(of: prompt) { _, _ in
            updateLayoutPriority()
            updateMinWidth()
        }
        .onAppear {
            formatInputText()
            updateLayoutPriority()
            updateMinWidth()
        }

    }
    private func formatInputText() {  //this will handle any input filtering (like only numbers, or only 3 digits)
        text = type.reconstruct(type.filter(text), &prompt)
        print("text: \(text), TFPrompt: \(prompt)")
    }

    //MARK: Update State Controller
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

    //MARK: Update Layout Priority Controller
    private func updateLayoutPriority() {
        // Higher priority for fields with more content
        let textLength = text.count
        let promptLength = prompt.count
        let totalContent = max(textLength, promptLength)

        // Base priority on content length and type
        contentPriority = 1.0 + (Double(totalContent) * 0.1)

        // Boost priority for fields that are actively being edited
        if isFocused {
            contentPriority += 0.5
        }

        // Special handling for different field types

        if type.fieldPriority < 1.0 {
            // cap the priority for smaller content at 1.2
            contentPriority = min(contentPriority, 1.2)
        } else {
            // priority floor for larger content is 1.3
            contentPriority = max(contentPriority, 1.3)
        }

    }
    private func updateMinWidth() {
        let minChars = max(10, text.count, prompt.count)
        cachedMinWidth = CGFloat(minChars) * 12
    }
}

#Preview {
    TFieldExamples()
}

public extension Tfield where T == TType {
    init(
        _ text: Binding<String>, type: TType = .phrase, required: Bool = false,
        label: String = ""
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        _prompt = State(initialValue: type.template)
    }
}

//MARK: TextFieldView
extension Tfield {
    var TextFieldView: some View {
        ZStack {
            // Custom background that matches across platforms
            Capsule()
                .fill(stateGradient)  // Use system background color
                .stroke(inputState.tintColor, lineWidth: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: inputState)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            TextField("", text: $text)
                .font(.system(.body, design: .monospaced))
                #if canImport(UIKit)
                    .keyboardType(type.keyboardType)
                #endif
                .autocorrectionDisabled(true)
                .focused($isFocused)
                #if canImport(AppKit)
                    .textFieldStyle(.plain)
                #endif
                .background(Color.clear)  // Ensure transparent background
                .overlay(alignment: .leading) {
                    Text("\(prompt)")
                        .font(.system(.body, design: .monospaced))
                        .frame(alignment: .trailing)
                        .offset(x: templateXOffset)
                        .offset(y: templateYOffset)
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                .padding(.horizontal)
        }
        .frame(height: 55)
        .frame(minWidth: cachedMinWidth, maxWidth: .infinity)
    }

    // State-responsive gradient:
    var stateGradient: LinearGradient {
        let baseOpacity: Double = isFocused ? 0.08 : 0.04

        switch inputState.validity {
        case .valid:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(baseOpacity * 3.0),
                    Color.blue.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .invalid:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(baseOpacity * 5.0),
                    Color.red.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(baseOpacity * 1.0),
                    Color.blue.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension Tfield {
    var floatingLabel: some View {

            Text(getLabel())
                .padding(.horizontal, 5)
                .background(labelBackground)
                .foregroundStyle(inputState.tintColor)
                .padding(.leading)
                .offset(y: labelOffset)
                .scaleEffect(labelScale)
                .onTapGesture {
                    isFocused = true
                }
        
    }

    var requiredIndicator: some View {

            Text(required ? "*" : "")
            .font(.title)
                .foregroundColor(.red)
                .padding(.horizontal, 5)
                .background(.clear)
                .offset(y: -24)
        
    }

    //Dynamic label background
    var labelBackground: Color {
        if isLabelFloating {
            #if canImport(UIKit)
                return Color(UIColor.systemBackground)
            #else
                return Color(NSColor.windowBackgroundColor)
            #endif
        } else {
            return Color.clear
        }

    }
    var isLabelFloating: Bool {
        if case .idle = inputState, text.isEmpty && prompt.isEmpty {
            return false
        }
        return true
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
                    .padding(.leading, 4)
                    .padding(.trailing, 4)

                    .background(errorBackground)
                    .padding(.leading)
                    .offset(y: errorOffset)
                    .offset(x: 10)
                    .padding(.top, 4)
            }
        }
    }
    var errorBackground: Color {
       
#if canImport(UIKit)
            return Color(UIColor.systemBackground)
#else
            return Color(NSColor.windowBackgroundColor)
#endif
        
    }
}  // makeErrorMessage

extension Tfield {
    @ViewBuilder
    func makeStateMessage() -> some View {
        Group {
            if debugging {
                
                Text(
                    "\(String(describing: type)) / \(inputState.description) / P:\(String(format: "%.1f", contentPriority))"
                ).foregroundStyle(inputState.debugDescriptionColor)
                    .bold(required)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading)
                    .offset(y: debugOffset)
                    .offset(x: -10)
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
        default: return 18
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
            height += 0
        }
        if debugging {
            height += 12
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

    var templateXOffset: CGFloat {
        var offset = 0
        #if canImport(UIKit)
            offset = 1
        #else
            offset = 1
        #endif
        return CGFloat(offset)
    }

    var templateYOffset: CGFloat {
        var offset = 0
        #if canImport(UIKit)
            switch inputState {
            case .focused(.invalid), .inactive(.invalid):
                offset = 1
            default:
                offset = 0
        }
        #else
        switch inputState {
        case .focused(.invalid), .inactive(.invalid):
            offset = 0
        default:
            offset = 0
        }


        #endif
        return CGFloat(offset)
    }
}  // offset calculations for floating elements
