//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

public protocol TBType {
    
    
    // Required by protocol.  This is the default string that will be used if none provided by the calling view
    var description: String { get }
    
    // Number indicating the field priority for the field if needs to be shrunk.  1.0 is  Standard.  values 0-.99 shrink first, generally lower capapcity field, like age (2 or 3 digits).  1.1 - 2.0 are numbers used currenly to restrict priority.  5+ would almost NEVER shrink.  10.0 is the max value.
    var fieldPriority: Double { get }

    // This is a text string representing the input template overlay that may be displayed, such as "(000) 000-0000"  If you do not provide it, then none will be displayed.  This is represented by an empty string in the implementation, which is why the default is an empty string.  Please note, if you provide an input filter, you must also provide four closures - filter, reconstruct, validateLive, and validateResult.
    var template: String { get }

    #if canImport(UIKit)
        // KeyboardType that will be used.  Not used in MacOS
        var keyboardType: UIKeyboardType { get }
    #endif

    /* This is a closure which accepts the Data, and an error string, and returns a boolean indicating if the input is valid as it is being typed.  It is able to do real time character by character error checking.  for instance, if you are entering a two digit month, you could verify that the first digit is either 0 or 1.  If not, set the error string (the inout string) and return false.  Otherwise, return true  The inout string is not used at all in the case of a true result.  Note that in some cases, this is not necessary if filtered input does not allow any improper characters.  Thus the optional value of true if this is not implemented.
     example closure below...
     switch self {
     case .newCase:
        return {text, errorMessage in
            code to validate
            If Valid {
                errorMessage = "This is an Error"
                return False
            } else {
                return true
            }
        }
     }
     */
    var validateLive: (String, inout String) -> Bool { get }

    /* This is a closure of similar form to above.  It will verify the final entry when the box looses focus.  If you are entering a date, for instance, you could use formatInput to verify that each digit makes sense... "mm/dd/yyyy" First digit of month makes sense (0 or 1) then second digit (first two digits are 01 - 12) then next digit is 0-3, then next two digits are 1-31, then when the year is entered and the focus moves on, you can use this closure to verify that the date actually exists - ie 02/31 is an error.  02/29 is sometimes an error, sometimes not depending on year.  You do not need to test for required.  That functionality is baked in to the view already.  The default if not provided is true - no error checking.

     switch self {
     case .newCase:
        return {text, errorMessage in
            code to validate
            If Valid {
                errorMessage = "This is an Error"
                return False
            } else {
                return true
            }
        }
     }
     */
    var validateResult: (String, inout String) -> Bool { get }

    /*
     The following closure will accept the current data with any formatting, including whatever the last user input was.  It will filter the user input for character type, such as numbers only, maximum length, and it will return an unformatted string with just the data.  For instance, if there was an input template of "MM/YY", the filter would remove the "/" character if it is in the string, check that the user input was numeric (disallow otherwise), and check the maximum length is 4 characters, then return the unformatted value.  Note the format template formatting characters may be part of the input string, but the formatting placeholders will not be part of the string in the case of a partial or incomplete data string
     switch self {
     case .newCase:
        return {text in
            code to validate input character and filter formatting characters
            return unformatted string
        }
     }
     */
    var filter: (String) -> String { get }

    /*
     The reconstruct closure will accept a string (the unformatted data) and an inout string (no value at the start, but set to the value of the partial input template upon completion), and returns a formatted data string.  The full value of the input template is specified in self.template.  The  value of the inout parameter at completion will be dependant on how complete the string is.  for instance, if the original template is "000-000-0000", and $0 is "123", then $1 should be set to "   -000-0000", and the return string would be "123".  If $0 is "1234" then $1 should be set to "     00-0000" and the return string should be "123-4".  If reconstruct is called with an empty string, then $1 should be the original input template, and an empty string should be returned.
     It can be assumed that the original string input is valid, but may be incomplete.  It will not be to many characters or if the data is a particular character type, such as numbers, then the data will only contain numbers.

     switch self {
     case .newCase:
        return {inputString, partialTemplate in
            code to add formatting to the inputString
            partialTemplate = template with spaces replacing any existing data
            return formattedString
        }
     }
     */
    var reconstruct: (String, inout String) -> String { get }
}




// Default implementations provided for convenience...
extension TBType {

    public var template: String { "" }
    public var validateLive: (String, inout String) -> Bool { { _, _ in true } }
    public var validateResult: (String, inout String) -> Bool {
        { _, _ in true }
    }
    public var filter: (String) -> String { { $0 } }
    public var reconstruct: (String, inout String) -> String {
        return { first, second in
            second = ""
            return first
        }
    }
    #if canImport(UIKit)
    public var keyboardType: UIKeyboardType { .default }
    #endif

}
