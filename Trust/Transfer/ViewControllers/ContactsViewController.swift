// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import RealmSwift
import TrustCore
import TrustKeystore

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var tableView = UITableView()
    let contact = Contact()
    var contacts = [MyStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        setNavBar()
        setTableView()
    }
    func deleteContact(name: String){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Contact.self).filter("name=%@", name))
        }
    }
    func addNewContact(_ name: String, _ address: String){
        let realm = try! Realm()
        contact.address = address
        contact.name = name
        try! realm.write {
            realm.add(contact)
        }
    }
    
    
    func getContacts(){
        let people = try! Realm().objects(Contact.self)
        for person in people{
            contacts.append(MyStruct(name: person.name!, address: person.address!))
        }
    }
    
    func setTableView(){
        tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "my")
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/8, width: displayWidth, height: displayHeight - barHeight)
        let contentSize = self.tableView.contentSize
        view.addSubview(tableView)
    }
    
    func setNavBar(){
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/8))
        navBar.barTintColor = UIColor.white
        self.view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Contacts")
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButton))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed(sender:)))
        addItem.tintColor = .black
        doneItem.tintColor = .black
        navItem.leftBarButtonItem = doneItem
        navItem.rightBarButtonItem = addItem
        navBar.setItems([navItem], animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath)
        cell.textLabel?.text = contacts[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contacts.isEmpty{
            return 0
        } else {
        return contacts.count
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteContact(name: contacts[indexPath.row].name!)
            contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    @objc func addPressed(sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Add new contact", message: "Please enter name and ETH address", preferredStyle: UIAlertControllerStyle.alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let nameTextField = alert.textFields![0] as UITextField
            let addressTextField = alert.textFields![1] as UITextField
            if let getName = nameTextField.text {
                guard let address = Address(string: addressTextField.text!) else {
                    return self.displayError(error: Errors.invalidAddress)
                }
                let queue1 = DispatchQueue(label: "pushRow1", qos: DispatchQoS.userInitiated)
                let queue2 = DispatchQueue(label: "pushRow2", qos: DispatchQoS.utility)
                queue1.sync {
                    self.addNewContact(getName, address.eip55String)
                }
                queue2.sync {
                    self.contacts = []
                    self.getContacts()
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Enter a name"
        }
        alert.addTextField { (addressTextField) in
            addressTextField.placeholder = "Enter address"
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func backButton(){
        self.dismiss(animated: true, completion: nil)
    }

}
