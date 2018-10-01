// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CryptosViewController: UITableViewController {
    
    
    
    var result: DataResult? = nil
    var itemsToLoad: [String] = ["Bitcoin", "Ether", "Ripple","Bitcoin Cash", "EOS", "Stellar Lumens","Litecoin", "Tether", "Cardano","Monero", "IOTA", "DigitalCash","Tron", "Neo", "Ethereum Classic","Binance Coin", "Tezos", "NEM","Vechain", "DogeCoin", "Zcash"]
    var itemsPriceToLoad: [String] = ["$6,620", "$221", "$0.5372","$538", "$5.82", "$0.2519","$62", "$0.9980", "$0.0845","$116", "$0.5712", "$200","$0.0220", "$19", "$11","$9.94", "$1.20", "$0.1100","$0.0130", "$0.0059", "$136"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = "ALL Cryptos"
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        getInfo()
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.title = "ALL Cryptos"
//
//
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToLoad.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        }
        cell!.textLabel?.text = itemsToLoad[indexPath.row]
        cell!.detailTextLabel?.text = itemsPriceToLoad[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("User selected table row \(indexPath.row) and item \(itemsToLoad[indexPath.row])")
    }
    
    func getInfo() {
        WebServiceHandler.sharedInstance.getCryptos { (res) in
            if let webServiceResult = res as? DataResult {
                self.result = webServiceResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
