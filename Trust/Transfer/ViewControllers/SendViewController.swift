// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Eureka
import JSONRPCKit
import APIKit
import BigInt
import QRCodeReaderViewController
import TrustCore
import TrustKeystore
import RealmSwift
import Parse
import PhoneNumberKit

protocol SendViewControllerDelegate: class {
    func didPressConfirm(
        transaction: UnconfirmedTransaction,
        transferType: TransferType,
        in viewController: SendViewController
    )
}
class SendViewController: FormViewController{
    var serverPubKey = ""
    var inputCase = ""
    var mystruct: MyStruct?
    var getData:[MyStruct] = []
    let contact = Contact()
    let phoneNumberKit = PhoneNumberKit()
    @IBOutlet weak var editButton: UIBarButtonItem!
    private lazy var viewModel: SendViewModel = {
        return .init(transferType: transferType, config: session.config, chainState: session.chainState, storage: storage, balance: session.balance)
    }()
    weak var delegate: SendViewControllerDelegate?
    struct Values {
        static let address = "address"
        static let email = "email"
        static let phone = "phone"
        static let amount = "amount"
        static let collectible = "collectible"
    }
    struct SendTypeValues {
        static let address = "ETH Address"
        static let email = "Email"
        static let phone = "Phone"
        static let contacts = "Contacts"
        static let segment = "segment"
    }
    let session: WalletSession
    let account: Account
    let transferType: TransferType
    let storage: TokensDataStore
    var segmentRow: SegmentedRow<String>? {
        return form.rowBy(tag: SendTypeValues.segment)
    }
    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.address) as? TextFloatLabelRow
    }
    var emailRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.email) as? TextFloatLabelRow
    }
    var phoneRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.phone) as? TextFloatLabelRow
    }
    var amountRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.amount) as? TextFloatLabelRow
    }
    lazy var maxButton: UIButton = {
        let button = Button(size: .normal, style: .borderless)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("send.max.button.title", value: "Max", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(useMaxAmount), for: .touchUpInside)
        return button
    }()
    private var allowedCharacters: String = {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        return "0123456789" + decimalSeparator
    }()
    private var data = Data()
    init(
        session: WalletSession,
        storage: TokensDataStore,
        account: Account,
        transferType: TransferType = .ether(destination: .none)
        ) {
        self.session = session
        self.account = account
        self.transferType = transferType
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: R.string.localizable.next(),
            style: .done,
            target: self,
            action: #selector(send)
        )
        
        getContacts()
        
        
        form
            +++ Section(){
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 0 }
                }
            <<< SegmentedRow<String>(SendTypeValues.segment){
                $0.options = [
                    SendType.ETHAddress.title,
                    SendType.email.title,
                    SendType.phone.title,
                    SendType.contacts.title,
                ]
                $0.value = SendType.ETHAddress.title
                }.cellUpdate({ (cell, row) in
                    cell.tintColor = UIColor(hex: "15A7EB")
                })
            
            +++ Section() {
                $0.tag = "Recipient_s"
                $0.hidden = Eureka.Condition.function([SendTypeValues.segment], { [weak self] _ in
                    return self?.segmentRow?.value != SendType.ETHAddress.title
                })
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            <<< addressField()

            +++ Section() {
                $0.tag = "cellPhone_s"
                $0.hidden = Eureka.Condition.function([SendTypeValues.segment], { [weak self] _ in
                    return self?.segmentRow?.value != SendType.phone.title
                })
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            <<< cellPhoneField()
            
            +++ Section() {
                $0.tag = "Email_s"
                $0.hidden = Eureka.Condition.function([SendTypeValues.segment], { [weak self] _ in
                    return self?.segmentRow?.value != SendType.email.title
                })
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            <<< emailField()
            
            +++ Section() {
                $0.tag = "Contacts_s"
                $0.hidden = Eureka.Condition.function([SendTypeValues.segment], { [weak self] _ in
                    return self?.segmentRow?.value != SendType.contacts.title
                })
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            <<< PushRow<MyStruct>(SendType.contacts.title){
                $0.title = $0.tag
                $0.value = mystruct
                $0.displayValueFor = {
                    guard let person = $0 else { return nil }
                      return person.name
                    }
                $0.cellUpdate { cell, row in
                    row.options = self.getData
                }
                
                }.onPresent({ (from, to) in
                    self.inputCase = "address"
                    to.enableDeselection = false
                    to.dismissOnSelection = false
                    to.selectableRowCellUpdate = { (cell, row) in
                        
                        let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { (_ , _ , completionHandler) in
                            let str: MyStruct = self.getData[(row.indexPath?.row)!]
                            self.getData.remove(at: (row.indexPath?.row)!)
                            if let getName = str.name{
                                self.deleteContact(name: getName)
                           }
                            completionHandler?(true)
                        
                        })
                        row.trailingSwipe.actions = [deleteAction]
                        row.trailingSwipe.performsFirstActionWithFullSwipe = false
                    }
                }).cellUpdate({ (cell, row ) in
                    cell.height = {55}
                    row.options = self.getData
                    let address = self.form.rowBy(tag: Values.address) as! RowOf<String>
                    address.value = row.value?.address
                    address.updateCell()
                })
            
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 0 }
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            
            <<< AmountField()
            <<< TextFloatLabelRow(){
                $0.tag = "labelTag"
                }.cellUpdate({ (cell, _) in
                    cell.textField.placeholder = R.string.localizable.sendPairValue()
                    cell.textLabel?.textAlignment = .left
                    cell.backgroundColor = UIColor.clear
                    cell.textField.font = .italicSystemFont(ofSize: 12)
                })

            +++ Section() {
                $0.tag = "Recipient_s"
                $0.hidden = Eureka.Condition.function([SendTypeValues.segment], { [weak self] _ in
                    return self?.segmentRow?.value != SendType.ETHAddress.title
                })
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 0 }
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { 0 }
            }
            <<< ButtonRow() {
                $0.title = NSLocalizedString("send.addContacts.button.title", value: "", comment: "")
                $0.onCellSelection(self.buttonTapped)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()
    }

    
    private func fields() -> [BaseRow] {
        return viewModel.views.map { field(for: $0) }
    }

    private func field(for type: SendViewType) -> BaseRow {
        switch type {
        case .address:
            return addressField()
        case .amount:
            return AmountField()
        case .collectible(let token):
            return collectibleField(with: token)
        }
    }

    func addressField() -> TextFloatLabelRow {
        let recipientRightView = FieldAppereance.addressFieldRightView(
            pasteAction: { [unowned self] in self.pasteAction() },
            qrAction: { [unowned self] in self.openReader() }
        )
        return AppFormAppearance.textFieldFloat(tag: Values.address) {
            $0.add(rule: EthereumAddressRule())
            $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.recipientAddress.textField.placeholder", value: "Recipient Address", comment: "")
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
                cell.textField.accessibilityIdentifier = "amount-field"
                cell.textField.keyboardType = .default
                cell.separatorInset = UIEdgeInsetsMake(10, 50, 0, 50)
            }.onCellHighlightChanged({ (cell, row) in
                if row.isHighlighted == true {
                    self.inputCase = "address"
                }
            })
    }
    
    func emailField() -> TextFloatLabelRow {
        let recipientRightView = FieldAppereance.emailCellPhoneFieldRightView(
            pasteAction: { [unowned self] in self.emailPasteAction()
            }
        )
        return AppFormAppearance.textFieldFloat(tag: Values.email) {
            $0.validationOptions = .validatesOnDemand
            } .cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.segmentRow.email", value: "Email", comment: "")
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
                cell.textField.accessibilityIdentifier = "email-field"
                cell.textField.keyboardType = UIKeyboardType.default
                cell.textField.autocorrectionType = UITextAutocorrectionType.no
                cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
            }.onCellHighlightChanged({ (cell, row) in
                if row.isHighlighted == true {
                    self.inputCase = "email"
                }
            })
    }
    
    func cellPhoneField() -> TextFloatLabelRow {
        let recipientRightView = FieldAppereance.emailCellPhoneFieldRightView(
            pasteAction: { [unowned self] in self.phonePasteAction() }
        )
        return AppFormAppearance.textFieldFloat(tag: Values.phone) {
            $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.segmentRow.phone", value: "Phone", comment: "")
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
                cell.textField.accessibilityIdentifier = "cellPhone-field"
                cell.textField.keyboardType = UIKeyboardType.numberPad
            } .onCellHighlightChanged({ (cell, row) in
                if row.isHighlighted == true {
                    self.inputCase = "phone"
                }
            })
    }

    func AmountField() -> TextFloatLabelRow {
        let fiatButton = Button(size: .normal, style: .borderless)
        fiatButton.translatesAutoresizingMaskIntoConstraints = false
        fiatButton.setTitle(viewModel.currentPair.right, for: .normal)
        fiatButton.addTarget(self, action: #selector(fiatAction), for: .touchUpInside)
        fiatButton.isHidden = viewModel.isFiatViewHidden()
        let amountRightView = UIStackView(arrangedSubviews: [
            maxButton,
            fiatButton,
            ])
        amountRightView.translatesAutoresizingMaskIntoConstraints = false
        amountRightView.distribution = .equalSpacing
        amountRightView.spacing = 1
        amountRightView.axis = .horizontal
        return AppFormAppearance.textFieldFloat(tag: Values.amount) {
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnDemand
            }.cellUpdate {[weak self] cell, _ in
                cell.textField.isCopyPasteDisabled = true
                cell.textField.textAlignment = .left
                cell.textField.delegate = self
                cell.textField.placeholder = "\(self?.viewModel.currentPair.left ?? "") " + NSLocalizedString("send.amount.textField.placeholder", value: "Amount", comment: "")
                cell.textField.keyboardType = .decimalPad
                cell.textField.rightView = amountRightView
                cell.textField.rightViewMode = .always
            }.onChange({ row in
                let address = self.form.rowBy(tag:  "labelTag") as! RowOf<String>
                address.value = self.viewModel.pairRateRepresantetion()
                address.updateCell()
            })
    }

    func collectibleField(with token: NonFungibleTokenObject) -> SendNFTRow {
        let cell = SendNFTRow(tag: Values.collectible)
        let viewModel = NFTDetailsViewModel(token: token)
        cell.cellSetup { cell, _ in
            cell.tokenImage.kf.setImage(
                with: viewModel.imageURL,
                placeholder: viewModel.placeholder
            )
            cell.label.text = viewModel.title
        }
        return cell
    }
    
    func getAddress(_ emailOrPhone: String, _ getCase: String) -> String {
        var getValue = " "
        var params = [String: String]()
        if getCase == "email" {
            params["email"] = emailOrPhone
        } else if getCase == "phone"{
            do {
                let num = try phoneNumberKit.parse( emailOrPhone )
                let phoneNum = phoneNumberKit.format(num, toType: .e164)
                params["phone"] = phoneNum
            } catch {
                print(error.localizedDescription)
            }
        } else {
            return getValue
        }
        do {
            let requestAddress = try PFCloud.callFunction("queryAddress", withParameters: params)
            getValue = requestAddress as! String
        } catch {
            requestPubKeyfromServer(param: params)
            return getValue
        }
        return getValue
    }
    
    func requestPubKeyfromServer(param: [String: String]){
        let alert = UIAlertController(title: "", message: NSLocalizedString("send.queryAddress.errorMessage", comment: ""), preferredStyle: .alert)
        let actionYes = UIAlertAction(title: NSLocalizedString("send.queryAddress.yes", comment: ""), style: .default) { _ in
            do {
                let createWallet = try PFCloud.callFunction("createWallet", withParameters: param)
                self.serverPubKey = createWallet as! String
            } catch {
                print(error.localizedDescription)
                self.hideLoading()
                return
            }
            params = param
            self.inputCase = ""
            self.hideLoading()
            self.send()
        }
        let actionNo = UIAlertAction(title: NSLocalizedString("send.queryAddress.no", comment: ""), style: .cancel) { (_) in
            self.hideLoading()
        }
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(alert, animated: true, completion: nil)
    }

    func clear() {
        let fields = [addressRow, amountRow]
        for field in fields {
            field?.value = ""
            field?.reload()
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
    
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Contact.self))
        }
    }
    
    func deleteContact(name: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Contact.self).filter("name=%@", name))
        }
    }
    
    func getContacts() {
        let people = try! Realm().objects(Contact.self)
        for person in people {
            getData.append(MyStruct(name: person.name!, address: person.address!))
        }
    }
    
    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow){
        guard let address = Address(string: addressRow?.value?.trimmed ?? "") else {
            return self.displayError(error: Errors.invalidAddress)
        }
        let alert = UIAlertController(title: NSLocalizedString("send.addNewContacts.alertController.title", value: "Add New Contact", comment: ""), message: NSLocalizedString("send.addNewContacts.alertController.message", value: "Please enter name and ETH address", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        let addAction = UIAlertAction(title: NSLocalizedString("send.addNewContacts.alertAction.okButton", value: "ADD", comment: ""), style: .default) { (action) in
            let nameTextField = alert.textFields![0] as UITextField
            if let getName = nameTextField.text {
                self.addNewContact(getName, address.eip55String)
                self.getData.append(MyStruct(name: getName, address: address.eip55String))
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("send.addNewContacts.alertAction.cancelButton", value: "Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = NSLocalizedString("send.addNewContacts.textField.placeholder", value: "Enter a name", comment: "")
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func send() {
        let errors = form.validate()
        let amountString = viewModel.amount
        guard errors.isEmpty else { return }
        let receivedAddress: String?
        switch inputCase {
        case "email":
            if (emailRow?.value)!.isEmail {
                self.displayLoading(text: "", animated: true)
                receivedAddress = getAddress(emailRow?.value?.trimmed ?? "", inputCase)
            } else {
                self.hideLoading()
                return displayError(error: Errors.invalidEmail)
            }
        case "phone":
            if (phoneRow?.value)!.isPhoneNumber {
                self.displayLoading(text: "", animated: true)
                receivedAddress = getAddress(phoneRow?.value?.trimmed ?? "", inputCase)
            } else {
                self.hideLoading()
                return displayError(error: Errors.invalidPhoneNumber)
            }
        default:
            if serverPubKey == "" {
                receivedAddress = addressRow?.value?.trimmed ?? ""
            } else {
                receivedAddress = serverPubKey
            }
        }
        guard let address = Address(string: receivedAddress!) else {
            return displayError(error: Errors.invalidAddress)
        }
        let parsedValue: BigInt? = {
            switch transferType {
            case .ether, .dapp, .nft:
                return EtherNumberFormatter.full.number(from: amountString, units: .ether)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            }
        }()
        guard let value = parsedValue else {
            return displayError(error: SendInputErrors.wrongInput)
        }
        let transaction = UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: address,
            data: data,
            gasLimit: .none,
            gasPrice: viewModel.gasPrice,
            nonce: .none
        )
        self.hideLoading()
        self.delegate?.didPressConfirm(transaction: transaction, transferType: transferType, in: self)
    }
    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    @objc func pasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }
        guard CryptoAddressValidator.isValidAddress(value) else {
            return displayError(error: Errors.invalidAddress)
        }
        addressRow?.value = value
        addressRow?.reload()
        activateAmountView()
    }
    @objc func emailPasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }
        emailRow?.value = value
        emailRow?.reload()
        activateAmountView()
    }
    @objc func phonePasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }
        phoneRow?.value = value
        phoneRow?.reload()
        activateAmountView()
    }
    @objc func useMaxAmount() {
        amountRow?.value = viewModel.sendMaxAmount()
        updatePriceSection()
        amountRow?.reload()
    }
    @objc func fiatAction(sender: UIButton) {
        let swappedPair = viewModel.currentPair.swapPair()
        //New pair for future calculation we should swap pair each time we press fiat button.
        viewModel.currentPair = swappedPair
        //Update button title.
        sender.setTitle(viewModel.currentPair.right, for: .normal)
        //Hide max button
        maxButton.isHidden = viewModel.isMaxButtonHidden()
        //Reset amountRow value.
        amountRow?.value = nil
        amountRow?.reload()
        //Reset pair value.
        viewModel.pairRate = 0.0
        //Update section.
        updatePriceSection()
        //Set focuse on pair change.
        activateAmountView()
    }
    func activateAmountView() {
        amountRow?.cell.textField.becomeFirstResponder()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func updatePriceSection() {
        //Update section only if fiat view is visible.
        guard !viewModel.isFiatViewHidden() else {
            return
        }
        //We use this section update to prevent update of the all section including cells.
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        if let containerView = tableView.footerView(forSection: 1) {
            containerView.textLabel!.text = viewModel.pairRateRepresantetion()
            containerView.sizeToFit()
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
extension SendViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        reader.dismiss(animated: true) { [weak self] in
            self?.activateAmountView()
        }

        guard let result = QRURLParser.from(string: result) else { return }
        addressRow?.value = result.address
        addressRow?.reload()

        if let dataString = result.params["data"] {
            data = Data(hex: dataString.drop0x)
        } else {
            data = Data()
        }

        if let value = result.params["amount"] {
            amountRow?.value = EtherNumberFormatter.full.string(from: BigInt(value) ?? BigInt(), units: .ether)
        } else {
            amountRow?.value = ""
        }
        amountRow?.reload()
        viewModel.pairRate = 0.0
        updatePriceSection()
    }
}
extension SendViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let input = textField.text else {
            return true
        }
        //In this step we validate only allowed characters it is because of the iPad keyboard.
        let characterSet = NSCharacterSet(charactersIn: self.allowedCharacters).inverted
        let separatedChars = string.components(separatedBy: characterSet)
        let filteredNumbersAndSeparator = separatedChars.joined(separator: "")
        if string != filteredNumbersAndSeparator {
            return false
        }
        //This is required to prevent user from input of numbers like 1.000.25 or 1,000,25.
        if string == "," || string == "." ||  string == "'" {
            return !input.contains(string)
        }
        //Total amount of the user input.
        let stringAmount = (input as NSString).replacingCharacters(in: range, with: string)
        //Convert to deciaml for pair rate update.
        let amount = viewModel.decimalAmount(with: stringAmount)
        //Update of the pair rate.
        viewModel.updatePairPrice(with: amount)
        updatePriceSection()
        //Update of the total amount.
        viewModel.updateAmount(with: stringAmount)
        return true
    }
}
