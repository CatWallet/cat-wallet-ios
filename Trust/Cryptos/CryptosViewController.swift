// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CryptosViewController: UITableViewController {
    
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
        return result.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        }
        cell!.textLabel?.text = result[indexPath.row].name
        //cell!.detailTextLabel?.text = itemsPriceToLoad[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //print("User selected table row \(indexPath.row) and item \(itemsToLoad[indexPath.row])")
    }
    
    func getInfo() {
        WebServiceHandler.sharedInstance.getCryptos { (res) in
            if let webServiceResult = res as?  [CryptosData]{
                result = webServiceResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
