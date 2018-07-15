// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

class Utils {
    
    static func openURL(urlstring: String!, navcontroller: UINavigationController?) {
        let url = URL(string: urlstring)
        if let nc = navcontroller {
            UIApplication.shared.open(url!, options: [:], completionHandler: .none)
        }
        
    }
}
