// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum SendType{
    case ETHAddress
    case email
    case phone
    case contacts
    
    var title: String {
        switch self {
        case .ETHAddress:
            return NSLocalizedString("send.segmentRow.ethAddress", value: "ETH Address", comment: "")
        case .email:
            return NSLocalizedString("send.segmentRow.email", value: "Email", comment: "")
        case .phone:
            return NSLocalizedString("send.segmentRow.phone", value: "Phone", comment: "")
        case .contacts:
            return NSLocalizedString("send.segmentRow.contacts", value: "Contacts", comment: "")
        }
    }
    
    init(title: String?) {
        switch title {
        case SendType.email.title?:
            self = .email
        case SendType.phone.title?:
            self = .phone
        case SendType.contacts.title?:
            self = .contacts
        default:
            self = .ETHAddress
        }
    }
}
