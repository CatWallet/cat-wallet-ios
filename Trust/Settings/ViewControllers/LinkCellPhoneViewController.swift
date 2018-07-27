// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Eureka


final class LinkCellPhoneViewController: FormViewController{
    
    let viewModel = LinkCellPhoneViewModel()
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        form +++ Section()
            <<< TextRow(){
                $0.placeholder = "Cell Phone Number"
                
            }
            +++ Section()
            <<< ButtonRow(){
                $0.title = "CONFIRM"
        }
    }
    
    
}
