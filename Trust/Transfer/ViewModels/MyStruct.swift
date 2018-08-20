// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

struct MyStruct {
    var name: String?
    var address: String?
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

class Contact: Object {
    @objc dynamic var name: String?
    @objc dynamic var address: String?
}
