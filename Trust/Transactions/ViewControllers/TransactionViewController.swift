// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import StackViewController
import Result
import SafariServices

protocol TransactionViewControllerDelegate: class {
    func didPressURL(_ url: URL)
}

final class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionDetailsViewModel = {
        return TransactionDetailsViewModel(
            transaction: self.transaction,
            config: self.config,
            chainState: ChainState(server: tokenViewModel.server),
            currentAccount: tokenViewModel.currentAccount,
            currencyRate: session.balanceCoordinator.currencyRate,
            server: tokenViewModel.server,
            token: tokenViewModel.token
        )
    }()
    let stackViewController = StackViewController()

    let session: WalletSession
    let transaction: Transaction
    let transactionsStore: TransactionsStorage
    let config = Config()
    let tokenViewModel: TokenViewModel
    weak var delegate: TransactionViewControllerDelegate?

    init(
        session: WalletSession,
        transaction: Transaction,
        transactionsStore: TransactionsStorage,
        tokenViewModel: TokenViewModel
    ) {
        self.session = session
        self.transaction = transaction
        self.transactionsStore = transactionsStore
        self.tokenViewModel = tokenViewModel

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = TransactionAppearance.spacing

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let header = TransactionHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.configure(for: viewModel.transactionHeaderViewModel)

        let dividerColor = Colors.whisper
        let dividerOffset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)

        let confirmationView = item(title: viewModel.confirmationLabelTitle, value: viewModel.confirmation)
        confirmationView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        var items: [UIView] = [
            .spacer(),
            header,
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.addressTitle, value: viewModel.address),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(
                title: viewModel.transactionIDLabelTitle,
                value: viewModel.transactionID,
                subTitleMinimumScaleFactor: 1
            ),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.gasFeeLabelTitle, value: viewModel.gasFee),
            TransactionAppearance.divider(color: dividerColor, alpha: 1),
            TransactionAppearance.horizontalItem(views: [
                confirmationView,
                TransactionAppearance.divider(direction: .vertical, color: dividerColor, alpha: 1, layoutInsets: .zero),
                item(title: viewModel.createdAtLabelTitle, value: viewModel.createdAt),
            ]),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.nonceTitle, value: viewModel.nonce),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
        ]

        items.append(notesView())

        if viewModel.detailsAvailable {
            items.append(moreDetails())
        }

        for item in items {
            stackViewController.addItem(item)
        }
        stackViewController.stackView.preservesSuperviewLayoutMargins = true

        displayChildViewController(viewController: stackViewController)

        if viewModel.shareAvailable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        }
    }

    private func item(
        title: String,
        value: String,
        subTitleMinimumScaleFactor: CGFloat  = 0.7
    ) -> UIView {
        return  TransactionAppearance.item(
            title: title,
            subTitle: value,
            subTitleMinimumScaleFactor: subTitleMinimumScaleFactor
        ) { [weak self] in
            self?.showAlertSheet(title: $0, value: $1, sourceView: $2)
        }
    }

    private func moreDetails() -> UIView {
        let button = Button(size: .large, style: .border)
        button.setTitle(R.string.localizable.moreDetails(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(more), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }

    private func notesView() -> UIView {
        let button = Button(size: .large, style: .border)
        button.setTitle(R.string.localizable.transactionAddNotes(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editNote), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [button])

        if let transactionNotes = transactionsStore.getNotes(forPrimaryKey: transaction.uniqueID),
            !transactionNotes.notes.isEmpty {
            let noteLabel = UILabel()
            noteLabel.font = UIFont.systemFont(ofSize: 15)
            noteLabel.textAlignment = .center
            noteLabel.translatesAutoresizingMaskIntoConstraints = false
            noteLabel.numberOfLines = 0
            noteLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            noteLabel.text = transactionNotes.notes
//            noteLabel.adjustsFontSizeToFitWidth = true
            noteLabel.sizeToFit()
            stackView.insertArrangedSubview(noteLabel, at: 0)

            // if we already have notes, button needs to say Edit instead
            button.setTitle(R.string.localizable.transactionEditNotes(), for: .normal)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }

    func showAlertSheet(title: String, value: String, sourceView: UIView) {
        let alertController = UIAlertController(
            title: nil,
            message: value,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        let copyAction = UIAlertAction(title: NSLocalizedString("Copy", value: "Copy", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = value
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in }
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func more() {
        guard let url = viewModel.detailsURL else { return }
        delegate?.didPressURL(url)
    }

    @objc func editNote() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: R.string.localizable.transactionNotesTitle(), message: R.string.localizable.transactionNotesDetails(), preferredStyle: .alert)
        
        //2. Add the text field
        alert.addTextField { [weak self] (textField) in
            guard let `self` = self else { return }
            if let transactionNotes = self.transactionsStore.getNotes(forPrimaryKey: self.transaction.uniqueID) {
                textField.text = transactionNotes.notes
            }
        }
        
        // 3. Grab the value from the text field when done
        alert.addAction(UIAlertAction(title: R.string.localizable.oK(), style: .default, handler: { [weak self, weak alert] (_) in
            guard let `self` = self else { return }
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            let transactionNotes = TransactionNotes()
            transactionNotes.uniqueID = self.transaction.uniqueID
            transactionNotes.notes = textField.text!
            self.transactionsStore.addNotes([transactionNotes])

            // refresh subview. This is assuming notesView is second to last, this assumption could change in the future
            self.stackViewController.removeItemAtIndex( self.stackViewController.items.count - 2 )
            self.stackViewController.insertItem(self.notesView(), atIndex: self.stackViewController.items.count - 2 )
        }))
        alert.addAction( UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: nil)  )

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    @objc func share(_ sender: UIBarButtonItem) {
        guard let item = viewModel.shareItem else { return }
        let activityViewController = UIActivityViewController.make(items: [item])
        activityViewController.popoverPresentationController?.barButtonItem = sender
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
