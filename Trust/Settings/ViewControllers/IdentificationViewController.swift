// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Parse
import Eureka
import ImageRow

class IdentificationViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++
            Section(R.string.localizable.identificationImageRowSectionTitle())
            <<< ImageRow("imageRow") {
                $0.title = R.string.localizable.identificationImageRowTitle()
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.clearAction = .yes(style: .destructive)
            }
        
            +++ Section()
            <<< ButtonRow("buttonRow") {
                $0.title = R.string.localizable.identificationButtonRowTitle()
            }.onCellSelection({ (row, cell) in
                    self.uploadIdentity()
                })
    }
    
    func uploadIdentity() {
        let row = form.rowBy(tag: "imageRow") as! ImageRow
        if let value = row.value {
            let imageData = UIImagePNGRepresentation(value)
            let currentUser = PFUser.current()
            if currentUser != nil {
                displayLoading()
                let imageFile = PFFile (name:"ID.png", data:imageData!)
                currentUser!["imageFile"] = imageFile
                currentUser!.saveInBackground(block: { (_, error) in
                    if error == nil {
                        self.hideLoading()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.hideLoading()
                        print(error.debugDescription)
                    }
                })
            }
        }
    }
}
