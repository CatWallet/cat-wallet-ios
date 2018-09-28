// Copyright DApps Platform Inc. All rights reserved.


import Foundation

struct CryptosData: Codable {
    var rank, name, price ,percent_change_1h : String
}

struct DataResult: Codable {
    var Cryptos: [CryptosData]
}
