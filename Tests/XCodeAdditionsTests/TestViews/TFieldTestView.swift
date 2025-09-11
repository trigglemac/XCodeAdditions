//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI
@testable import XCodeAdditions

struct TTestView: View {
    @State private var text: String = ""
    @State private var text1: String = ""
    @State private var text2: String = ""
    @State private var text3: String = "1224"
    @State private var text4: String = "1234"
    @State private var text5: String = "1234567891234567"
    @State private var text6: String = ""
    @State private var text7: String = ""
    @State private var text8: String = ""
    var body: some View {
        VStack {
            Tfield($text, type: .phrase, label: "Hobby")
            Tfield($text1, type: .name, required: true, label: "Enter your Full Name")
            Tfield($text2)
            Tfield($text3, type: .expDate)
            Tfield($text4, type: .cvv)
            Tfield($text5, type: .credit)
            Tfield($text6, type: .date, required: false)
            Tfield($text7, type: .age(min:65, max: 110), label: "Enter your Retirement Age")
        }
        .padding()
    }
}
