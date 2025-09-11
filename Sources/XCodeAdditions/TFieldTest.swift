//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/12/25.
//


import SwiftUI

@available(iOS 17.0, macOS 15.0, *)
public struct TFieldExamples: View {
    @State private var test1 = ""
    @State private var test2 = ""
    @State private var test3 = ""
    @State private var test4 = ""
    @State private var test5 = ""
    @State private var test6 = ""
    @State private var test7 = ""
    @State private var test8 = ""
    @State private var test9 = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Tfield($test1, type: .credit)
            Tfield($test2, type: .expDate, required: true, label: "Exp Date")
            Tfield($test3, type: .name, label: "Enter Your Full Name")
            Tfield($test4)
                .autocorrectionDisabled(true)
            Tfield($test5, type: .dataLength(length: 10), label: "Enter your 10 digit code")
            Tfield($test6, type: .phrase, required: false, label: "Enter Info")  // Same as default
            Tfield($test7, type: .cvv, required: true)
            Tfield($test8, type: .age(min: 65, max: 120), label: "Enter your Age")
            Tfield($test9, type: .date)
        }
        .padding()
    }
}

struct TFieldExamples_Previews: PreviewProvider {
    static var previews: some View {
        TFieldExamples()
            .previewDisplayName("TField Examples")
    }
}

/*
 public enum TType: TBType, Equatable {
     case data  //Current Default!  single alphanumeric string, no spaces allowed
     case dataLength(length: Int)  // single alphanumeric string, specified length
     case name  //name  Alpha string any length, allowed spaces, capitalized
     case phrase  //phrase  alphanumeric string, spaces are allowed
     case credit  // 16 digit card number grouped in 4's
     case expDate  // MM/YY
     case cvv  // 3 digit numeric number.  3 digits required
     case age(min: Int, max: Int)  //two digit age within the specified range
     case date  // mm/dd/yyyy
 }
 */

