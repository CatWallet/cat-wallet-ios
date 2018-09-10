// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Parse
import PhoneNumberKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var registerHelpLabel: UILabel!
    @IBOutlet weak var registerIdentityField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBOutlet weak var skipButton: UIButton!
    var initialWallet : WalletInfo?
    weak var appCoordinator : AppCoordinator?
    var sentCode = false
    var emailVerification = true
    var savedPhoneOrEmail = ""
    var cloudCodePending = false

    let phoneNumberKit = PhoneNumberKit()
    
    private let refreshControl = UIRefreshControl()
    
    
    
    @IBAction func registerMethodSelected(_ sender: Any) {
        registerIdentityField.text = ""
        if segmentControl.selectedSegmentIndex == 0 {
            emailVerification = true
            registerIdentityField.placeholder = R.string.localizable.registerEnterEmail()
        }
        else {
            emailVerification = false
            registerIdentityField.placeholder = R.string.localizable.registerEnterPhone()
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        appCoordinator?.showTransactions(for: initialWallet!)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showBusy() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }

    private func stopShowBusy() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    // prepare to enter phone number/email
    func step1() {
        sentCode = false
        sendButton.isEnabled = true
        cloudCodePending = false
        segmentControl.isHidden = false
        
        registerMethodSelected( segmentControl )  // pretend button clicked, to initialize field
        sendButton.setTitle( R.string.localizable.registerSendButton(), for: .normal)
        registerHelpLabel.text = R.string.localizable.registerSignupHelp()
    }
    
    // get phone number/email, but prepare to confirm verification code
    func step2() {
        sentCode = true         // mark we have sent the code, to move to next step in state machine
        
        sendButton.isEnabled = true
        cloudCodePending = false
        segmentControl.isHidden = true

        registerIdentityField.text = ""
        registerIdentityField.placeholder = R.string.localizable.registerEnterCode()

        registerHelpLabel.text = R.string.localizable.registerConfirmCodeHelp()
        sendButton.setTitle( R.string.localizable.registerConfirmButton(), for: .normal)
    }

    func setButtonTitle(){
        segmentControl.setTitle(NSLocalizedString("register.segmentControl.title0", comment: ""), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("register.segmentControl.title1", comment: ""), forSegmentAt: 1)
        skipButton.setTitle(NSLocalizedString("register.skipButton.title", comment: ""), for: .normal)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func checkKeyStore(){
        let currentUser = PFUser.current()
        if currentUser != nil{
            if let keystore = currentUser!["keyStore"]{
                let we = WelcomeViewController()
                appCoordinator?.didPressImportWallet(in: we)
            }
        }
    }

    
    @IBAction func sendClicked(_ sender: Any) {
        let input = registerIdentityField.text!.lowercased().trimmed
        if input.isEmpty {
            showAlert(title: R.string.localizable.registerEmptyError(), message: "")
            return
        }

        if cloudCodePending { return }
        cloudCodePending = true
        sendButton.isEnabled = false

        if !sentCode {   // Send user verification code
            var params = ["email": input]
            savedPhoneOrEmail = input
            if !emailVerification {
                do {
                    let num = try phoneNumberKit.parse( input )
                    savedPhoneOrEmail = phoneNumberKit.format(num, toType: .e164)
                    params = ["phone":  savedPhoneOrEmail]
                }
                catch {
                    // TODO some number fail because no area code, can we figure out my area code to add to it?
                    showAlert(title: R.string.localizable.registerNumberInvalid(), message: "")
                    sendButton.isEnabled = true
                    cloudCodePending = false
                    return
                }
            }

            showBusy()
            PFCloud.callFunction(inBackground: "sendCode", withParameters: params) { [weak self] (results : Any?, error : Error?) -> Void in
                self?.stopShowBusy()
                if error != nil {
                    self?.step1()
                    self?.showAlert(title: R.string.localizable.registerSendCodeErrorTitle(),
                                    message: R.string.localizable.registerSendCodeErrorMessage() + error!.localizedDescription)
                }
                else {
                    self?.step2()
                }
            }
        }
        else {   // user got code back, need to log user in
            var params = ["code" : registerIdentityField.text!]
            if emailVerification {
                params["email"]  = savedPhoneOrEmail
            }
            else {
                params["phone"]  = savedPhoneOrEmail
            }

            showBusy()
            PFCloud.callFunction(inBackground: "logIn", withParameters: params) {
                [weak self] (response: Any?, error: Error?) -> Void in
                self?.stopShowBusy()
                if let error = error {
                    self?.step1()
                    self?.showAlert(title: R.string.localizable.registerLoginErrorTitle(),
                                    message: R.string.localizable.registerSendCodeErrorMessage() + error.localizedDescription  )
                }
                else if let token = response as? String {
                    PFUser.become(inBackground: token) { (user: PFUser?, error: Error?) -> Void in
                        if let error = error {
                            self?.showAlert(title: R.string.localizable.registerAssignUserErrorTitle(),
                                            message: R.string.localizable.registerSendCodeErrorMessage() + error.localizedDescription )
                            self?.step1()
                        }
                        else {
                            self?.checkKeyStore()
                            self?.dismiss(animated: true, completion: nil)
                            self?.appCoordinator?.showTransactions(for: self!.initialWallet!)
                        }
                    }
                }
                else {
                    self?.showAlert(title: R.string.localizable.registerAssignUserErrorTitle(),
                                    message: R.string.localizable.registerSendCodeErrorMessage() )
                    self?.step1()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTitle()
        step1()
    }

}
