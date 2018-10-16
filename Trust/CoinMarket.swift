// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct CoinMarket: Decodable {
    let data : [CoinData]
}

struct CoinData: Decodable {
    let id: Int
    let name: String
    let quote: CoinQuote
}

struct CoinQuote: Decodable {
    let USD: CoinUSD
}

struct CoinUSD: Decodable {
    let price: Double
    let percent_change_1h: Double
}
