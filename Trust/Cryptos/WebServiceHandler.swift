// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Foundation

typealias completionHandler = (Any)->()

final class WebServiceHandler: NSObject {
    static var sharedInstance = WebServiceHandler()
    private override init() {}
    
    func getCryptos(completion: @escaping completionHandler) {
        var result: DataResult? = nil
        URLSession.shared.dataTask(with: apiURL!) { (data, response, error) in
            guard error == nil else {
                print("API call failed")
                return
            }
            do {
               // let jsonDecoder = JSONDecoder()
                let decoder = JSONDecoder()
                // Swift 4.1
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                result = try decoder.decode(DataResult.self, from: data!)
                //decode(DataResult.self, from: data!)
                completion(result)
            } catch let jsonErr{
                print("Decode Failed", jsonErr)
                return
            }
        }.resume()
    }
}
