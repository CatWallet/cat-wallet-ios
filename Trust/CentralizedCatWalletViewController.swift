// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import WebKit

class CentralizedCatWalletViewController: UIViewController {

    var web: WKWebView = WKWebView()
    
    override func viewWillAppear(_ animated: Bool) {
        setWebView()
    }
    
    private func setWebView() {
        let scrrenSize = UIScreen.main.bounds
        let screentWidth = scrrenSize.width
        let screenHeight = scrrenSize.height
        web.frame = CGRect(x: 0, y: 0, width: screentWidth, height: screenHeight)
        self.view.addSubview(web)
        let url = URL(string: "https://www.youtube.com")
        let task = URLSession.shared.dataTask(with: url!) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            } else {
                print("something wrong")
            }
        }
        task.resume()
        let request = URLRequest(url: url!)
        print(request)
        web.load(request)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
