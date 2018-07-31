// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

// used to localize strings in XIB
protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}


//class Utils {
//
//    static func openURL(urlstring: String!, navcontroller: UINavigationController?) {
//        let url = URL(string: urlstring)
//        if let nc = navcontroller {
//            UIApplication.shared.open(url!, options: [:], completionHandler: .none)
//        }
//
//    }
//}
