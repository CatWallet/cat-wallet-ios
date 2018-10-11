// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinMarketTableViewController: UITableViewController, Coordinator {
    var coordinators: [Coordinator] = []
    var coinData = [CoinData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CoinMarketTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        //tableView.register(CoinMarketTableViewCell.self, forCellReuseIdentifier: "myCell")
        self.title = R.string.localizable.marketTabbarItemTitle()
        getInfo()
        //navigationController?.navigationBar.prefersLargeTitles = true
        //navigationItem.title = R.string.localizable.marketTabbarItemTitle()

        // self.clearsSelectionOnViewWillAppear = false
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getInfo() {
        WebServiceHandler.sharedInstance.getCoin { (res) in
            if let webServiceResult = res as? [CoinData] {
                self.coinData = webServiceResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CoinMarketTableViewCell
        cell.textLabel?.text = coinData[indexPath.row].name
        let price = coinData[indexPath.row].quote.USD.price
        cell.priceLabel.text = "$" + String(price)
        return cell
    }
    
    func currencyFormatter (Price: NSNumber) -> String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        let priceString = currencyFormatter.string(from: Price)!
        return String(priceString)
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
