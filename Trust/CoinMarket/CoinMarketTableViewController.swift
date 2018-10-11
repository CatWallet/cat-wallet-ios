// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CoinMarketTableViewController: UITableViewController, Coordinator {
    var coordinators: [Coordinator] = []
    var coinData = [CoinData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CoinMarketTableViewCell.self, forCellReuseIdentifier: "coinMArketCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinMArketCell", for: indexPath)
        cell.textLabel?.text = coinData[indexPath.row].name
        //cell.detailTextLabel?.text = String(coinData[indexPath.row].price)

        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }

}
