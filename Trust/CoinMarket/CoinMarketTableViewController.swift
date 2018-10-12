// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinMarketTableViewController: UITableViewController, Coordinator {
    var coordinators: [Coordinator] = []
    var coinData = [CoinData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CoinMarketTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
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
        cell.nameLabel.text = coinData[indexPath.row].name
        let price = coinData[indexPath.row].quote.USD.price
        let priceChange = coinData[indexPath.row].quote.USD.percent_change_1h
        
        if priceChange > 0 {
            cell.priceChangeLabel.textColor = UIColor.blue
            cell.priceLabel.textColor = UIColor.blue
        } else {
            cell.priceChangeLabel.textColor = UIColor.red
            cell.priceLabel.textColor = UIColor.red
        }
        cell.priceChangeLabel.text = String(format: "%.3f", priceChange)
        cell.priceLabel.text = "$" + String(format: "%.4f", price)
        return cell
    }
    
    func currencyFormatter (Price: NSNumber) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        let priceString = currencyFormatter.string(from: Price)!
        return String(priceString)
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CoinMarketDetialViewController(nibName: "CoinMarketDetialViewController", bundle: nil)
            if let navigator = navigationController {
                vc.title = coinData[indexPath.row].name
                navigator.pushViewController(vc, animated: true)
        }
    }
}
