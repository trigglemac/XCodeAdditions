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

/* This is the TType enum definition.  To Add a type, you must first add a case to this enum, then you must add an appropriate case statement to each of the extensions...  This includes the following...
 1. Required : description.  This is the default label description that will be used if nothing is provided
 2. template: This is the template for the input string.  return "" if no template is appropriate
 3. useFilter: calculated based on template.  Dont need to mess with it
 4. keyboardType: what type of keyboard to use for this control
 5. validateLive: closure that will handle live character by character validation.  It will accept the initial partially formatted string, and do any value based verification.  Input filtering should be handled first by the filter closure
 6. validateResult: closure that handles any validation upon loss of focus.  Partial entry is an example.  Required status is handled automatically and does not need to be addressed.
 7. filter: closure that handles input filtering... such as max length or limited characters like numbers only.  It should return an unformatted string (data only, no formatting characters)
 8. reconstruct: closure that accepts an unformatted data string, and filters back in the formatting characters, and at the same time resets the input template so that any characters that exist have spaces replacing those characters at the beginning of the template.

 
*/

public enum TType: TBType, Equatable {
    case data  //Current Default!  single alphanumeric string, no spaces allowed
    case dataLength(length: Int)  // single alphanumeric string, specified length
    case name  //name  Alpha string any length, allowed spaces, capitalized, limited punctuation (period, space, dash, apostrophe)
    case phrase  //phrase  alphanumeric string, spaces are allowed
    case credit  // 16 digit card number grouped in 4's
    case expDate  // MM/YY
    case cvv  // 3 digit numeric number.  3 digits required
    case age(min: Int, max: Int)  //two digit age within the specified range
    case date  // mm/dd/yyyy
    case streetnumber //Numbers only, no template, length <= 6, no formatting, cant be 0
    case street // Capitalized, spaces and punctuation allowed.
    
}

extension TType {
    public var description: String {
        switch self {
        case .data:
            return "Data"
        case .dataLength(let length):
            return "Data(\(length) characters)"
        case .name:
            return "Name"
        case .phrase:
            return "Enter Info"
        case .credit:
            return "Credit Card Number"
        case .cvv:
            return "CVV"
        case .expDate:
            return "Expiration Date"
        case .age(let min, let max):
            return "Age(\(min)-\(max))"
        case .date:
            return "Date"
        case .streetnumber:
            return "Street #"
        case .street:
            return "Street Name"
        }
    }
}

extension TType {
    public var template: String {
        switch self {
        case .data:
            return ""
        case .dataLength(let length):
            return String(repeating: "X", count: length)
        case .name:
            return ""
        case .phrase:
            return ""
        case .credit:
            return "0000 0000 0000 0000"
        case .expDate:
            return "MM/YY"
        case .cvv:
            return "000"
        case .age(_, let max):
            return max >= 100 ? "000" : "00"
        case .date:
            return "MM/DD/YYYY"
        case .streetnumber:
            return ""
        case .street:
            return ""
        }
    }
}

extension TType {
    var useFilter: Bool {
        return self.template != ""
    }
}  // var useFilter = False if template == "", else true

extension TType {
    public var fieldPriority: Double {
        switch self {
        case .data: return 1.0
        case .dataLength(_): return 1.1
        case .name: return 1.5
        case .phrase: return 1.7
        case .credit: return 1.5
        case .expDate: return 0.5
        case .cvv: return 0.5
        case .age(_,_): return 0.5
        case .date: return 1.0
        case .streetnumber: return 0.6
        case .street: return 1.5
            
            
        }
    }
}

#if canImport(UIKit)
extension TType {
    public var keyboardType: UIKeyboardType {
        switch self {
        case .data:
            return .default
        case .dataLength(length: _):
            return .default
        case .name:
            return .default
        case .phrase:
            return .default
        case .credit:
            return .numberPad
        case .expDate:
            return .numberPad
        case .cvv:
            return .numberPad
        case .age(min: _, max: _):
            return .numberPad
        case .date:
            return .numberPad
        case .streetnumber:
            return .numberPad
        case .street:
            return .default
        }
    }
}
#endif

extension TType {  // This will handle any data verification as numbers are being entered
    public var validateLive:
        (_ text: String, _ errorMessage: inout String) -> Bool
    {
        //  Each closure should return a Bool based on the intermediate validity, and if their is an error, set the errorMessage to the proper error description.  Note the value entered is not updated.  It is up to the user to delete and enter valid data

        switch self {
        case .data:  // Any data is allowed, except no spaces...
            return { text, errorMessage in
                // Check for spaces since filter removes them
                if text.contains(" ") {
                    errorMessage = "Spaces not allowed"
                    return false
                }
                return true
            }
        case .dataLength(_):
            return { text, errorMessage in
                // Check for spaces since filter removes them
                if text.contains(" ") {
                    errorMessage = "Spaces not allowed"
                    return false
                }
                // No need to check length here since filter handles truncation
                return true
            }
        case .name:
            return { text, errorMessage in
                // Check for invalid characters (numbers, special chars except spaces, hyphens, apostrophes)
                let allowedCharacterSet = CharacterSet.letters.union(
                    CharacterSet(charactersIn: ". '-"))
                if text.rangeOfCharacter(from: allowedCharacterSet.inverted)
                    != nil
                {
                    errorMessage =
                        "Only letters, spaces, hyphens, and apostrophes"
                    return false
                }
                return true
            }
        case .phrase:
            return { text, errorMessage in
                // profanity checks??
                return true
            }

        case .credit:  // Input filter handles all live error controls
            return { text, errorMessage in
                // Let filter handle most validation, but check for obvious issues
                let digitsOnly = text.filter { $0.isNumber }

                if digitsOnly.count == 1 {
                    // Simple card type validation based on first digit
                    let firstDigit = digitsOnly.prefix(1)
                    switch firstDigit {
                    case "4":  // Visa
                        break
                    case "5":  // Mastercard
                        break
                    case "3":  // Amex
                        break
                    case "6":  // Discover
                        break
                    default:
                        errorMessage = "Invalid credit type"
                        return false
                    }
                }
                return true
            }
        case .expDate:
            return { text, errorMessage in
                var digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if digitsOnly.count > 4 {
                    digitsOnly = String(digitsOnly.prefix(4))
                }
                switch digitsOnly.count {
                case 0:  // dont errorcheck empty string
                    return true
                case 1:  // Must be 0 or 1 to be valid month
                    errorMessage = "Invalid Month"
                    return digitsOnly.prefix(1) == "0"
                        || digitsOnly.prefix(1) == "1"
                case 2:  // first two digits must be between 1 and 12
                    if let month = Int(digitsOnly.prefix(2)) {
                        errorMessage = "Invalid Month"
                        return month > 0 && month < 13
                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                case 3:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test year
                            // +/-12 year window around current...
                            let thisYear = Calendar.current.component(
                                .year, from: Date())
                            let min = String(thisYear - 12).dropFirst(2).prefix(
                                1)
                            let max = String(thisYear + 12).dropFirst(2).prefix(
                                1)
                            if let minInt = Int(min), let maxInt = Int(max),
                                let yearInt = Int(
                                    digitsOnly.dropFirst(2).prefix(1))
                            {
                                if yearInt < minInt || yearInt > maxInt {
                                    errorMessage = "Year out of range"
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                errorMessage = "Invalid Month/Year #"  // This should not be possible
                                return false
                            }
                        }

                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                case 4:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test year
                            // +/-12 year window around current...
                            let thisYear = Calendar.current.component(
                                .year, from: Date())
                            let min = String(thisYear - 12).dropFirst(2).prefix(
                                2)
                            let max = String(thisYear + 12).dropFirst(2).prefix(
                                2)
                            if let minInt = Int(min), let maxInt = Int(max),
                                let yearInt = Int(
                                    digitsOnly.dropFirst(2).prefix(2))
                            {
                                if yearInt < minInt || yearInt > maxInt {
                                    errorMessage = "Year out of range"
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                errorMessage = "Invalid Month/Year #"  // This should not be possible
                                return false
                            }
                        }

                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                default:
                    return false  // this should not be possible with input filtering
                }
            }
        case .cvv:  // Input filter handles all error controls
            return { text, errorMessage in
                return true
            }
        case .age(let min, let max):  // Only a two or three digit numeric string, between the min and max values
            return { text, errorMessage in
                if text.isEmpty {
                    return true  // Don't validate empty input
                }

                guard let value = Int(text) else {  // should never happen, as input filtering guarantees a number, and first test guarantees not empty string
                    errorMessage = "INVALID AGE FORMAT"
                    return false
                }

                let expectedDigits = max >= 100 ? 3 : 2
                if text.count > expectedDigits {  // Also should not be possible if input filtering is working right
                    errorMessage = "Age cannot exceed \(max)"
                    return false
                }

                // For partial input, check if it could potentially be valid
                switch text.count {
                // we handled 0 with the empty string test
                case 1:
                    // if first digit is 0, and max is 3 digits, then return true
                    if value == 0 && max >= 100 {
                        return true
                    } else if value == 0 {  //and max < 100
                        errorMessage = "Age must be at least \(min)"
                        return false
                    }
                    // now test all non- zero cases...
                    let digit = value
                    let twoDigitStart = digit * 10
                    let twoDigitEnd = twoDigitStart + 9
                    let threeDigitStart = digit * 100
                    let threeDigitEnd = threeDigitStart + 99

                    let inputRange = min...max
                    let twoDigitRange = twoDigitStart...twoDigitEnd
                    let threeDigitRange = threeDigitStart...threeDigitEnd

                    // If there's any overlap, return true
                    if inputRange.overlaps(twoDigitRange)
                        || inputRange.overlaps(threeDigitRange)
                    {
                        return true
                    }

                    // Now handle false case with appropriate print
                    if max < twoDigitStart {
                        // max is less than the lowest possible number with that first digit
                        errorMessage = "Age cannot exceed \(max)"
                    } else if min > threeDigitEnd {
                        // min is greater than the highest possible number with that first digit
                        errorMessage = "Age must be at least \(min)"
                    } else if max < threeDigitStart {
                        // The max falls between the two-digit and three-digit ranges (i.e., in the gap)
                        errorMessage = "Age cannot exceed \(max)"
                    } else {
                        // Catch-all for unexpected case
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                    }

                    return false

                case 2:

                    guard text.count == 2, let digitsInt = Int(text),
                        (10...99).contains(digitsInt)
                    else {
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                        return false
                    }

                    // Interpret digits as a possible 2-digit number
                    let twoDigitValue = digitsInt

                    // Also, interpret digits as the prefix of a 3-digit number range: e.g., "23" → 230...239
                    let threeDigitStart = digitsInt * 10
                    let threeDigitEnd = threeDigitStart + 9

                    let inputRange = min...max

                    // Check if the two-digit value is directly in range
                    if inputRange.contains(twoDigitValue) {
                        return true
                    }

                    // Check if any of the three-digit possibilities fall in the range
                    if inputRange.overlaps(threeDigitStart...threeDigitEnd) {
                        return true
                    }

                    // Handle false case with proper error messages
                    if max < twoDigitValue {
                        // max is less than the 2-digit digits value (e.g., "90" but max is 80)
                        errorMessage = "Age cannot exceed \(max)"
                    } else if min > threeDigitEnd {
                        // min is higher than the highest 3-digit value from digits (e.g., min 250, digits "23" → max 239)
                        errorMessage = "Age must be at least \(min)"
                    } else if max < threeDigitStart {
                        // max falls between the 2-digit value and possible 3-digit expansions
                        errorMessage = "Age cannot exceed \(max)"
                    } else {
                        // Fallback case (rare)
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                    }
                    return false
                case 3:
                    if value < min {
                        errorMessage = "Age must be at least \(min)"
                        return false
                    }
                    if value > max {
                        errorMessage = "Age cannot exceed \(max)"
                        return false
                    }
                    return true

                default:
                    return true
                }
            }
        case .date:
            return { text, errorMessage in
                var digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if digitsOnly.count > 8 {
                    digitsOnly = String(digitsOnly.prefix(8))
                }
                switch digitsOnly.count {
                case 0:  // dont errorcheck empty string
                    return true
                case 1:  // Must be 0 or 1 to be valid month
                    errorMessage = "Invalid Month"
                    return digitsOnly.prefix(1) == "0"
                        || digitsOnly.prefix(1) == "1"
                case 2:  // first two digits must be between 1 and 12
                    if let month = Int(digitsOnly.prefix(2)) {
                        errorMessage = "Invalid Month"
                        return month > 0 && month < 13
                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 3:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test day
                            let day = digitsOnly.dropFirst(2).prefix(2)
                            if day == "0" || day == "1" || day == "2"
                                || day == "3"
                            {
                                return true
                            } else {
                                errorMessage = "Invalid Day"
                                return false
                            }
                        }

                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 4:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test day
                            if let day = Int(digitsOnly.dropFirst(2).prefix(2))
                            {
                                if day > 0 && day < 30 {
                                    return true
                                } else {
                                    errorMessage = "Invalid Day"
                                    return false
                                }
                            } else {
                                errorMessage = "INVALID DATE"  // This should not be possible
                                return false
                            }
                        }

                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 5...8:  // accept any 4 digit year
                    return true
                default:
                    return false  // this should not be possible with input filtering
                }
            }
        case .streetnumber:
            return { text, errorMessage in
                return true
            }
        case .street:
            return { text, errorMessage in
                return true
            }
        }
    }
}

extension TType {  // This will handle any data verification as numbers are being entered
    public var validateResult:
        (_ text: String, _ errorMessage: inout String) -> Bool
    {
        //  Each closure should return a Bool based on the intermediate validity, and if their is an error, set the errorMessage to the proper error description.  Note the value entered is not updated.  It is up to the user to delete and enter valid data

        switch self {
        case .data:  // Any data is allowed, except no spaces...
            return { text, errorMessage in
                return true
            }
        case .dataLength(let length):
            return { text, errorMessage in
                errorMessage = "Not Long Enough"
                return text.count >= length
            }

        case .name:
            return { text, errorMessage in
                return true
            }
        case .phrase:
            return { text, errorMessage in
                return true
            }
        case .credit:
            return { text, errorMessage in
                errorMessage = "Card Number Incomplete"
                return text.count >= self.template.count
            }
        case .expDate:
            return { text, errorMessage in
                if text.count != 5 {
                    errorMessage = "Incomplete Date"
                    return false
                }
                let digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if let month = Int(digitsOnly.prefix(2)) {
                    if month < 1 || month > 12 {
                        errorMessage = "Invalid Month"
                        return false
                    } else {  //month valid, test year
                        // +/-12 year window around current...
                        let thisYear = Calendar.current.component(
                            .year, from: Date())
                        let min = String(thisYear - 12).dropFirst(2).prefix(2)
                        let max = String(thisYear + 12).dropFirst(2).prefix(2)
                        if let minInt = Int(min), let maxInt = Int(max),
                            let yearInt = Int(digitsOnly.dropFirst(2).prefix(2))
                        {
                            if yearInt < minInt || yearInt > maxInt {
                                errorMessage = "Year out of range"
                                return false
                            } else {
                                return true
                            }
                        } else {
                            errorMessage = "Invalid Month/Year #"  // This should not be possible
                            return false
                        }
                    }

                } else {
                    errorMessage = "Invalid Month/Year #"  // This should not be possible
                    return false
                }

            }
        case .cvv:  // input filter handles numeric input.  Final number acceptable if 3 digits
            return { text, errorMessage in
                errorMessage = "CVV Incomplete"
                return text.count >= self.template.count
            }
        case .age(let min, let max):  // Only a two  digit numeric string, between the min and max values
            return { text, errorMessage in
                guard let value = Int(text) else {
                    errorMessage = "LOGIC ERROR VALIDATE LIVE"  // This should never happen because of input filtering
                    return false
                }
                switch value {
                case ..<min:
                    errorMessage = "Value is smaller than /(min)"
                    return false
                case (max + 1)...:
                    errorMessage = "Value is larger than /(max)"
                    return false
                default: return true
                }

            }
        case .date:
            return { text, errorMessage in
                let dateFormatter = DateFormatter()

                // Set the date format to match the input string
                dateFormatter.dateFormat = "MM/dd/yyyy"

                // Ensure the formatter uses the correct locale and timezone
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                // Attempt to convert the string to a Date object
                if let date = dateFormatter.date(from: text) {
                    // If the conversion is successful, check if the original string matches
                    if dateFormatter.string(from: date) == text {
                        return true
                    } else {
                        errorMessage = "Invalid Date"
                        return false
                    }
                }

                // Return false if conversion fails
                errorMessage = "Invalid Date"
                return false
            }
        case .streetnumber:
            return { text, errorMessage in
                if text == "0" {
                    errorMessage = "Street Number cannot be zero"
                    return false
                } else {
                    return true
                }
            }
        case .street:
            return { text, errorMessage in
                return true
            }
        }
    }

}

extension TType {
    /// Helper to get credit card type from number
    private func creditCardType(from number: String) -> String? {
        guard let firstDigit = number.first?.wholeNumberValue else {
            return nil
        }

        switch firstDigit {
        case 4: return "Visa"
        case 5: return "Mastercard"
        case 3:
            if number.hasPrefix("34") || number.hasPrefix("37") {
                return "American Express"
            }
            return nil
        case 6: return "Discover"
        default: return nil
        }
    }

}

extension TType {
    public var filter: (String) -> String {
        switch self {
        case .data:
            return { text in
                text.replacingOccurrences(
                    of: "\\s+", with: "", options: .regularExpression)
            }  // no spaces, single character string
        case .dataLength(let length):
            return { text in
                String(
                    text.replacingOccurrences(
                        of: "\\s+", with: "", options: .regularExpression).prefix(length))
            }  // same as .data, but specified length
        case .name:
            return { text in
                text.capitalized                
            }  // Multiple words, Proper Capitalization
        case .phrase:
            return { text in
                text
            }  //No filter or format at all
        case .credit:
            return { text in
                let inputText = text.filter { $0.isNumber || $0 == " " }
                let digitsOnly = inputText.replacingOccurrences(
                    of: " ", with: "")
                return String(digitsOnly.prefix(16))
            }  // 16 digit numeric
        case .expDate:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(4))
            }  // 4 numeric digits
        case .cvv:
            return { text in
                let digitsOnly = String(text.filter { $0.isNumber })
                return String(digitsOnly.prefix(3))
            }  // 3 numeric digits
        case .age(_, let max):
            return { text in
                let maxLength = max >= 100 ? 3 : 2
                return String(text.filter { $0.isNumber }.prefix(maxLength))
            }  //two or three digits depending on max > 99
        case .date:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(8))
            }
        case .streetnumber:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(6))
            }
        case .street:
            return { text in
                text.capitalized
            }
        }
    }
}  // .filter - responsible for input filtering and max length filtering.  returns an UNFORMATTED string

extension TType {
    public var reconstruct: (String, inout String) -> String {
        switch self {
        // text is the UNFORMATTED data.  self.template is the template to use.
        // format the data into the template, and replace the beginning of the template with spaces so that they line up properly.
        // Note that if there is no template applied, then simply return the original string and reset partialTemplat to "".
        case .data:
            return { text, partialTemplate in
                partialTemplate = ""
                return text
            }  // default behavior
        case .dataLength(_):
            return { text, partialTemplate in
                var formattedText = ""
                partialTemplate = self.template
                for (_, character) in text.enumerated() {
                    formattedText.append(character)
                    partialTemplate = String(partialTemplate.dropFirst())
                }
                let remainingSpaces = self.template.count - partialTemplate.count
                partialTemplate.insert(contentsOf: String(repeating: " ", count: remainingSpaces), at: partialTemplate.startIndex)
                return formattedText
            }  // default behavior
        case .name:
            return { text, partialTemplate in
                partialTemplate = ""
                return text.capitalized
            }  // Multiple words, Proper Capitalization
        case .phrase:
            return { text, partialTemplate in
                partialTemplate = ""
                return text
            }  //default behavior
        case .credit:
            return { digitsOnly, partialTemplate in
                var formattedText = ""
                partialTemplate = self.template
                for (index, character) in digitsOnly.enumerated() {
                    if index > 0 && index % 4 == 0 {
                        formattedText.append(" ")
                        partialTemplate = String(partialTemplate.dropFirst())
                    }
                    formattedText.append(character)
                    partialTemplate = String(partialTemplate.dropFirst())
                }
                while partialTemplate.count < self.template.count {
                    partialTemplate.insert(" ", at: partialTemplate.startIndex)
                }
                return formattedText
            }  // 16 digit numeric

        case .expDate:
            return { digitsOnly, partialTemplate in
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "MM/YY"
                    return ""
                case 1:
                    partialTemplate = " M/YY"
                    return digitsOnly
                case 2:
                    partialTemplate = "  /YY"
                    return digitsOnly
                case 3:
                    partialTemplate = "    Y"
                    return
                        "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))"
                case 4:
                    partialTemplate = "     "
                    return
                        "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))"
                default:
                    return ""  // This should never happen, because digitsonly is 0 to 4 characters
                }
            }  // 4 numeric digits
        case .cvv:
            return { digitsOnly, partialTemplate in
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "000"
                case 1:
                    partialTemplate = " 00"
                case 2:
                    partialTemplate = "  0"
                case 3:
                    partialTemplate = "   "
                default:
                    partialTemplate = ""  // This should never happen, because digitsonly is 0 - 3 characters
                }
                return digitsOnly
            }  // 3 numeric digits
        case .age(_, _):
            return { digitsOnly, partialTemplate in
                switch self.template.count {  // template will either be 2 or 3 digits
                case 2:
                    if digitsOnly.count == 0 {
                        partialTemplate = "00"
                    } else if digitsOnly.count == 1 {
                        partialTemplate = " 0"
                    } else {
                        partialTemplate = "  "
                    }
                case 3:
                    if digitsOnly.count == 0 {
                        partialTemplate = "000"
                    } else if digitsOnly.count == 1 {
                        partialTemplate = " 00"
                    } else if digitsOnly.count == 2 {
                        partialTemplate = "  0"
                    } else {
                        partialTemplate = "   "
                    }
                default:
                    partialTemplate = ""  // This should never happen
                }
                return digitsOnly
            }  //two or three digits depending on max > 99
        case .date:
            return { digitsOnly, partialTemplate in
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "MM/DD/YYYY"
                    return ""
                case 1:
                    partialTemplate = " M/DD/YYYY"
                    return "\(digitsOnly.prefix(1))"
                case 2:
                    partialTemplate = "  /DD/YYYY"
                    return "\(digitsOnly.prefix(2))"
                case 3:
                    partialTemplate = "    D/YYYY"
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(1))"
                case 4:
                    partialTemplate = "     /YYYY"
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))"
                case 5:
                    partialTemplate = "       YYY"
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))/\(digitsOnly.dropFirst(4).prefix(1))"
                case 6:
                    partialTemplate = "        YY"
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))/\(digitsOnly.dropFirst(4).prefix(2))"
                case 7:
                    partialTemplate = "         Y"
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))/\(digitsOnly.dropFirst(4).prefix(3))"
                case 8:
                    partialTemplate = ""
                    return "\(digitsOnly.prefix(2))/\(digitsOnly.dropFirst(2).prefix(2))/\(digitsOnly.dropFirst(4).prefix(4))"
                default:
                    partialTemplate = ""
                    return "ERROR" //this should never happen
                }
            }
        case .streetnumber:
            return { digitsOnly, partialTemplate in
                partialTemplate = ""
                return String(digitsOnly.prefix(6))
            }
        case .street:
            return { text, partialTemplate in
                partialTemplate = ""
                return text.capitalized
            }

        }
    }
}
