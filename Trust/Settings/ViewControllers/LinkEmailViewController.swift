// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Eureka

final class LinkEmailViewController: FormViewController{
    
    let viewModel = LinkEmailViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        
        form +++ Section()
            
            <<< TextRow(){
                $0.placeholder = "Email Address"
                
            }
            
            +++ Section()
            
            <<< ButtonRow(){
                $0.title = "CONFIRM"
        }
    }
}
