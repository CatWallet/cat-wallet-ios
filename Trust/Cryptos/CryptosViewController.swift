// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class CryptosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var myTableView: UITableView  =   UITableView()
    var itemsToLoad: [String] = ["One", "Two", "Three"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get main screen bounds
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        myTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        self.view.addSubview(myTableView)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.textLabel?.text = self.itemsToLoad[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("User selected table row \(indexPath.row) and item \(itemsToLoad[indexPath.row])")
    }

}
