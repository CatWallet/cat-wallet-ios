// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import WebKit

class CentralizedCatWalletViewController: UIViewController {

    var web: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        // Do any additional setup after loading the view.
    }
    
    private func setWebView() {
        let scrrenSize = UIScreen.main.bounds
        let screentWidth = scrrenSize.width
        let screenHeight = scrrenSize.height
        web.frame = CGRect(x: 0, y: 0, width: screentWidth, height: screenHeight)
        self.view.addSubview(web)
        let url = URL(string: "https://www.youtube.com")
        let request = URLRequest(url: url!)
        web.loadRequest(request)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
