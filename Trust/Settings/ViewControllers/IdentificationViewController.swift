// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import ImageRow

class IdentificationViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++
            Section(R.string.localizable.identificationImageRowSectionTitle())
            <<< ImageRow() {
                $0.title = R.string.localizable.identificationImageRowTitle()
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.clearAction = .yes(style: .destructive)
        }
    }
}

