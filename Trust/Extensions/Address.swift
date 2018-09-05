// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

import Foundation
import TrustCore

enum Errors: LocalizedError {
    case invalidAddress
    case invalidEmail
    case invalidPhoneNumber
    case invalidAmount

    case userNotRegistered
    
    var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return NSLocalizedString("send.error.invalidAddress", value: "Invalid Address", comment: "")
        case .invalidEmail:
            return NSLocalizedString("send.error.invalidEmail", value: "Invalid Email", comment: "")
        case .invalidPhoneNumber:
            return NSLocalizedString("send.error.invalidPhoneNUmber", value: "Invalid Phone Number", comment: "")
        case .invalidAmount:
            return NSLocalizedString("send.error.invalidAmount", value: "Invalid Amount", comment: "")
        case .userNotRegistered:
            return NSLocalizedString("send.error.userNotRegistered", value: "User is not registered", comment: "")
        }
    }
}

extension Address {
    static var zero: Address {
        return Address(string: "0x0000000000000000000000000000000000000000")!
    }
}

