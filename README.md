# XCodeAdditions

A SwiftUI package that contains an assortment of modified input controls.  Currently the only one inculded is Tfield : an enum driven state controlled textbox with self contained filtering, formatting, and validation.

## Tfield Features

- Simple calling function...  TField($text) will work with a default label of "Data", and no input filtering, or data validation
- More options as needed... TField($text, required: true, type: .credit, label: "Enter Credit Card Number")
- Ability to validate while typing... if an input template is specified, for instance type = .expDate, the input template is "MM/YY"  As digits are entered, they are validated for rather they could construct a valid expiration date
- Ability to use an input template... if an input template is specified, it is displayed on the field, and as each digit is entered, the template character is replaced by the actual character
- Input Filtering... If input is of a specific character set or length, ie expiration date would be 4 numeric digits, this is restricted real time and invalid input is not accepted
- Result Filtering... Once a field looses focus, a validation routine can be executed to verify if a required entry is present, if an entry is complete or partial, and if the final data is valid
- Floating Label... All types have a default label value, or one can be specified.  In either case, the label shows up inside the box if it is empty.  If there is an input template or data, the label will float up to the top of the box and remain visible
- enum driven state... All state is driven by enums to determine status - idle, active, or inactive, and validity - valid, or invalid(errorMessage).
- Error Messages built into data type... and displayed in real time automatically
- Type enum controls data type.  Add a case to the type enum, including all the extension variables, and you have a new viable type.
- All data is passed to and returned from the field in text format.  An initial value must be text, but need not be formatted.  Any offensive characters or extra length will be filtered and the string will be formatted before the data is presented in the view.
- Data is returned from the view as a formatted text string ready for print or display.  If you need a numeric value or date value for calculations, simply filter the formatting and convert.  

## How to Run
  
1. Import the package into your project
2. import XCodeAdditions on any file that makes use of the feature

## Tfield Usage
1. There are several types available.  As of this version, those types include the following...

    .data  Current Default!  single alphanumeric string, no spaces allowed
    .dataLength(length: Int)   single alphanumeric string, specified length
    .name   Alpha string(s) any length, spaces and limited puctuation, every word capitalized
    .phrase  alphanumeric string, spaces are allowed, no formatting or filtering at all
    .credit  16 digit card number grouped in 4's
    .expDate  CC expiration date in the format of  MM/YY
    .cvv   3 digit numeric number.  3 digits required
    .age(min: Int, max: Int) age inside specified range.  min is two digits, max is 2 or 3 digits
    .date  numeric string in the form of mm/dd/yyyy, with live and result validation
    .streetnumber - numeric number, max 6 digits, no commas
    .street - Similar to .name, but without restrictions on input.  Capitlaized

2. the control can be called with the view call...
    Tfield($text) // where text is any state variable in your view.  text will be accepted as a @Binding var text: String.
    
3. The default behavior is of type .phrase (No filtering, or validation), optional, and with an input string of "Enter Info".  You can modify any of these defaults by adding the type:, required:, and label: parameters to your call.
4. A few examples of calls might be as follows...

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

5. The view is implemented as a textfield inside of a vstack and a zstack, so some modifiers - such as .autocorrectionDisabled() may be added.  If it works, give it a try, but I have not tried a lot of this, so no guarantees it renders right even if it doesnt flake out.
6. If you don't see the data type you are looking for, you can implement it yourself by extending TType.  Instructions on how to do this are included next.


## Extending Tfield with additional types.
- You can extend Tfield by adding an extension with additional types.  You should start by adding the following code...

public enum MyCustomTypes: TBType {
    case zipCode
    case phoneNumber
    case socialSecurity
    
    public var description: String {
        switch self {
        case .zipCode: return "ZIP Code"
        case .phoneNumber: return "Phone Number"
        case .socialSecurity: return "Social Security Number"
        }
    }
    
    // ... implement other protocol requirements
}

- This is the minimum implementation required...  The behavior will simply be a new type which can be specified, and an automatic label value associated with this type.  It will not have any additional features such as an input template, filtering, or validation and errorchecking.  If you want those associated with your type, then you need to implement them by adding the following public var statements to your 



import SwiftUI
import XCodeAdditions

public enum MyCustomTypes: TBType {
    
    case zipCode
    case phoneNumber
    case socialSecurity
    
    public var description: String {
        switch self {
        case .zipCode: return "ZIP Code"
        case .phoneNumber: return "Phone Number"
        case .socialSecurity: return "SSN"
        }
    }
    
    public var template: String {
        switch self {
        case .zipCode: return "00000"
        case .phoneNumber: return "(000) 000-0000"
        case .socialSecurity: return "000-00-0000"
        }
    }
    
    // Platform-specific keyboard handling
#if canImport(UIKit)
    public var keyboardType: UIKeyboardType {
        switch self {
        case .zipCode:
            return .numberPad
        case .phoneNumber:
            return .phonePad
        case .socialSecurity:
            return .numberPad
        }
    }
#endif
    
    
    public var fieldPriority: Double {
        switch self {
        case .zipCode:
            return 0.6
        case .phoneNumber:
            return 0.9
        case .socialSecurity:
            return 0.8
        }
    }

        
    public var filter: (String) -> String {
        switch self {
        case .zipCode:
            return { text in
                String(text.filter { $0.isNumber }.prefix(5))
            }
        case .phoneNumber:
            return { text in
                String(text.filter { $0.isNumber }.prefix(10))
            }
        case .socialSecurity:
            return { text in
                String(text.filter { $0.isNumber }.prefix(9))
            }
        }
    }
    
    public var reconstruct: (String, inout String) -> String {
        switch self {
        case .zipCode:
            return { digitsOnly, partialTemplate in
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "00000"
                case 1:
                    partialTemplate = " 0000"
                case 2:
                    partialTemplate = "  0000"
                case 3:
                    partialTemplate = "   00"
                case 4:
                    partialTemplate = "    0"
                case 5:
                    partialTemplate = "     "
                default:
                    partialTemplate = ""  // This should never happen, because digitsonly is 0 - 3 characters
                }
                return digitsOnly
            }
        case .phoneNumber:
            return { digitsOnly, partialTemplate in
                // Implementation for (000) 000-0000 formatting
                var formattedDigits = ""
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "(000) 000-0000"
                    formattedDigits = ""
                case 1:
                    partialTemplate = "  00) 000-0000"
                    formattedDigits = "(\(digitsOnly.prefix(1))"
                case 2:
                    partialTemplate = "   0) 000-0000"
                    formattedDigits = "(\(digitsOnly.prefix(2))"
                case 3:
                    partialTemplate = "    ) 000-0000"
                    formattedDigits = "(\(digitsOnly.prefix(3))"
                case 4:
                    partialTemplate = "       00-0000"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(1))"
                case 5:
                    partialTemplate = "        0-0000"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(2))"
                case 6:
                    partialTemplate = "         -0000"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))"
               case 7:
                    partialTemplate = "           000"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(1))"
                case 8:
                    partialTemplate = "            00"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(2))"
                case 9:
                    partialTemplate = "             0"
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(3))"
                case 10:
                    partialTemplate = "              "
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(4))"
                default:
                    partialTemplate = ""  // This should never happen, because digitsonly is 0 - 3 characters
                }
                return formattedDigits
            }
        case .socialSecurity:
            return { digitsOnly, partialTemplate in
                // Implementation for 000-00-0000 formatting
                var formattedDigits: String = ""
                switch digitsOnly.count {
                case 0:
                    partialTemplate = "000-00-0000"
                    formattedDigits = ""
                case 1:
                    partialTemplate = " 00-00-0000"
                    formattedDigits = "\(digitsOnly.prefix(1))"
                case 2:
                    partialTemplate = "  0-00-0000"
                    formattedDigits = "\(digitsOnly.prefix(2))"
                case 3:
                    partialTemplate = "   -00-0000"
                    formattedDigits = "\(digitsOnly.prefix(3))"
                case 4:
                    partialTemplate = "     0-0000"
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(1))"
                case 5:
                    partialTemplate = "      -0000"
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))"
                case 6:
                    partialTemplate = "        000"
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(1))"
                case 7:
                    partialTemplate = "         00"
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(2))"
                case 8:
                    partialTemplate = "          0"
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(3))"
                case 9:
                    partialTemplate = "           "
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(4))"
                default:
                    partialTemplate = ""  // This should never happen, because digitsonly is 0 - 3 characters
                }
                return formattedDigits
            }
        }
    }

    public var validateLive: (_ text: String, _ errorMessage: inout String) -> Bool {
        switch self {
        case .zipCode:
            return { text, errorMessage in
                // implementation of character by character validation.  You know a character has been added or deleted.  Text is a formatted string value.  You do not need to check for length or numbers only, as that is done with filtering.  What you might do here is for instance, verify that the first digit of "MM/YY" is a 0 or a 1.  If not, error out because there is no way to enter a valid number otherwise.
                // if you return true, the value of errorMessage does not matter.  If you return false (invalid) then you must set your errorMessage to a string indicating the error description.
                // in the case of zipcode, we truly do not need to do any additional checking, because the filter handles it all
                // Also note you do NOT get to alter the data value at all.  You flag the error only.
                return true
            }
        case .phoneNumber:
            return { text, errorMessage in
                return true
            }
        case .socialSecurity:
            return { text, errorMessage in
                return true
            }
        }
    }
    
    public var validateResult: (_ text: String, _ errorMessage: inout String) -> Bool {
        switch self {
        case .zipCode:
            return { text, errorMessage in
                // code to verify result after the field looses focus - in otherwords, the final answer.
                // You do not need to test for required status.  You may want to test that either your final value is valid, or that the value is a complete value.
                // For instance, here you may want to verify that a five digit zip was entered, not a partial
                if text.count == 5 {
                    return true
                } else {
                    errorMessage = "Incomplete Zip Code"
                    return false
                }

            }
        case .phoneNumber:
            return { text, errorMessage in
                if text.count == 14 {
                    return true
                } else {
                    errorMessage = "Incomplete Phone #"
                    return false
                }
            }
        case .socialSecurity:
            return { text, errorMessage in
                if text.count == 11 {
                    return true
                } else {
                    errorMessage = "Incomplete SSN"
                    return false
                }
            }
        }
    }
}

- If you do not specify the other variables, the default implementation is as follows.
    keyboardType = .default
    template = "" //no input template
    validateLive, validateResult default to true, no data validation
    filter and reconstruct default to no action ie no filtering or formatting

- Once you have added the above example code, or something similar to your project, you should be able to call Tfield using your custome type implementations.

            Tfield($text, type: MyCustomTypes.phoneNumber)
            Tfield($text10, type: MyCustomTypes.zipCode, label: "Zip5")




## What's Next
- Known issue - Name validation and filtering does not work properly with the allowed punctuation.
- expecting to add additional data types, along with additional testing of the validation closures
- expecting to add optional badging for any type...  badges would show up to the right of the label
    badges would be updatable at any time, for instance, as soon as the first digit is entered in a credit, a badge indicating the type of card could be added to the label.  Additionally any required string may have a required badge added.
- expecting to add warning messages to supplement error messages.  Warning messages would be implemented in the validation routines.  An example might be warning that a credit is expired, or that that a password is easy
- expecting to eliminate the need for the reconstruct closure.  Instead, specify the placeholders in a string... this might be "0", or "MDY" for instance.  Then the reconstruct can be handled independantly with knowlege of the template.
- potentially add some totally custom TextFields to the package, such as a joined pair of password verification or email verification fields, or perhaps a date field with an attached date picker.  All would share the same formatting as the original.
- explore ways to expose the styling to users - the different state colors, the container shape, the background color, etc.  This should be accessible, but not as a parameter of the view to keep from overcomplicating things.
- timeline: honestly this is a hobby.  And I am an infant when it comes to XCode and practical usage.  Getting it into a user package is probably next, then a few more types like address, street, apt, city, and zip.  Uncertain on timeline.  Concurrent to that is probably learning more about GitHub cause hey - ive never done this before.


## Local Storage

The app currently does not use local storage

## Screenshots

maybe someday ill do this


## Version History
- version 1.0.2
    fixed the generic typing in TType to allow extensions to work properly
    adjusted template location by a couple pixels so it lined up better
    shifted the error message inside the capsule so that the field height stays consistent rather or not there is an error.
    adjusted size and location of Required indicator
    *known issues - versioning is not done right on GitHub, apostrophe in .name is not recognized, when lenght of view is shortened, label is not considered, when some fields are shortened you can tab into them but you cannot click into them, .credit verifies type on first digit, but then accepts a two digit or greater with invalid first digit.  adding .font(.title) to the field only affects the label - try to make it scale everything if possible.
    
- version 1.0.1:
    adjust spacing vertically and horizontally so template and field line up better on mac and iphone
    additional types : .streetnumber, .street
    added a red asterisk at the front of a field to indicate its required state
    added state based background to the textbox... light blue gradient for idle, darker blue gradient for valid, and red gradient for invalid state.
    fixed the macOS input not having the same background as the capsule
    added conditional background to the floating label... clear if in the middle of the field so as not to interfere with background gradient, and using system or window background color if floating, so that the background blocks out the capsule border
    Other tweaks to make light and dark mode work as expected.
    
- version 1.0.0: Initial Commit

## License

MIT
