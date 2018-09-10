// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

struct MyStruct : CustomStringConvertible, Equatable{
    var name: String?
    var address: String?
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    var description: String {
        return "\(self.name!)"
    }
}

class Contact: Object {
    @objc dynamic var name: String?
    @objc dynamic var address: String?
}

var params: [String: String]?
