// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Foundation

typealias completionHandler = (Any)->()

final class WebServiceHandler: NSObject {
    static var sharedInstance = WebServiceHandler()
    private override init() {}
    
    func getActors(completion: @escaping completionHandler) {
        var result: DataResult? = nil
        URLSession.shared.dataTask(with: apiURL!) { (data, response, error) in
            guard error == nil else {
                print("API call failed")
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                result = try jsonDecoder.decode(DataResult.self, from: data!)
                completion(result)
            } catch {
                print("Decode Failed")
                return
            }
            
            }.resume()
    }
}
