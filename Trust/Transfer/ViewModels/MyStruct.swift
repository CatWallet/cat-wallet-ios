// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct MyStruct : CustomStringConvertible,Equatable{
    var name: String?
    var address: String?
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    var description: String {
        return "\(self.name)"
    }
}
