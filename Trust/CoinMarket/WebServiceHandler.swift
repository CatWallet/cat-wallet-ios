// Copyright DApps Platform Inc. All rights reserved.

import Foundation

typealias completionHandler = (Any) ->()

final class WebServiceHandler: NSObject {
    static var sharedInstance = WebServiceHandler()
    private override init() {}
    
    func getCoin(completion: @escaping completionHandler) {
        var getCoinData = [CoinData]()
        guard let url = URL(string: apiURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let getData = try decoder.decode(CoinMarket.self, from: data)
                    getCoinData = getData.data
                    completion(getCoinData)
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
            }
        }.resume()
    }
}
