import UIKit
import RxSwift
import Keys

class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finished = PublishSubject<Void>()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!
    @IBOutlet weak var securitycodeTextField: TextField!
    @IBOutlet weak var billingZipTextField: TextField!

    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var securityCodeWrapperView: UIView!
    @IBOutlet weak var billingZipWrapperView: UIView!
    @IBOutlet weak var billingZipErrorLabel: UILabel!

    @IBOutlet weak var cardConfirmButton: ActionButton!
    @IBOutlet weak var dateConfirmButton: ActionButton!
    @IBOutlet weak var securityCodeConfirmButton: ActionButton!
    @IBOutlet weak var billingZipConfirmButton: ActionButton!

    lazy var keys = EidolonKeys()

    lazy var viewModel: ManualCreditCardInputViewModel = {
        var bidDetails = self.navigationController?.fulfillmentNav().bidDetails
        return ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: self.finished)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        expirationDateWrapperView.hidden = true
        securityCodeWrapperView.hidden = true
        billingZipWrapperView.hidden = true

        // We show the enter credit card number, then the date switching the views around
        viewModel
            .cardFullDigits
            .asObservable()
            .bindTo(cardNumberTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .expirationYear
            .asObservable()
            .bindTo(expirationYearTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .expirationMonth
            .asObservable()
            .bindTo(expirationMonthTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .securityCode
            .asObservable()
            .bindTo(securitycodeTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .billingZip
            .asObservable()
            .bindTo(billingZipTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel
            .creditCardNumberIsValid
            .bindTo(cardConfirmButton.rx_enabled)
            .addDisposableTo(rx_disposeBag)

        let action = viewModel.registerButtonCommand()
        billingZipConfirmButton.rx_action = action

        action
            .errors // Based on errors
            .take(1) // On the first error, then forever
            .mapReplace(false) // Replace the error with false
            .startWith(true) // But begin with true
            .bindTo(billingZipErrorLabel.rx_hidden) // show the error label
            .addDisposableTo(rx_disposeBag)

        viewModel.moveToYear.take(1).subscribeNext { [weak self] _ in
            self?.expirationYearTextField.becomeFirstResponder()
        }.addDisposableTo(rx_disposeBag)

        cardNumberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return viewModel.isEntryValid(string)
    }

    @IBAction func cardNumberconfirmTapped(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = false
        securityCodeWrapperView.hidden = true
        billingZipWrapperView.hidden = true

        expirationDateWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(expirationDateWrapperView.frame), CGRectGetHeight(expirationDateWrapperView.frame))

        expirationMonthTextField.becomeFirstResponder()
    }

    @IBAction func expirationDateConfirmTapped(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = true
        securityCodeWrapperView.hidden = false
        billingZipWrapperView.hidden = true

        securityCodeWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(securityCodeWrapperView.frame), CGRectGetHeight(securityCodeWrapperView.frame))

        securitycodeTextField.becomeFirstResponder()
    }

    @IBAction func securityCodeConfirmTapped(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = true
        securityCodeWrapperView.hidden = true
        billingZipWrapperView.hidden = false

        billingZipWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(billingZipWrapperView.frame), CGRectGetHeight(billingZipWrapperView.frame))

        billingZipTextField.becomeFirstResponder()
    }

    @IBAction func backToCardNumber(sender: AnyObject) {
        cardNumberWrapperView.hidden = false
        expirationDateWrapperView.hidden = true
        securityCodeWrapperView.hidden = true
        billingZipWrapperView.hidden = true

        cardNumberTextField.becomeFirstResponder()
    }

    @IBAction func backToExpirationDate(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = false
        securityCodeWrapperView.hidden = true
        billingZipWrapperView.hidden = true

        expirationMonthTextField.becomeFirstResponder()
    }

    @IBAction func backToSecurityCode(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = true
        securityCodeWrapperView.hidden = false
        billingZipWrapperView.hidden = true

        securitycodeTextField.becomeFirstResponder()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ManualCreditCardInputViewController {
        return storyboard.viewControllerWithID(.ManualCardDetailsInput) as! ManualCreditCardInputViewController
    }
}

private extension ManualCreditCardInputViewController {
    func applyCardWithSuccess(success: Bool) {
        cardNumberTextField.text = success ? "4242424242424242" : "4000000000000002"
        cardNumberTextField.sendActionsForControlEvents(.AllEditingEvents)
        cardConfirmButton.sendActionsForControlEvents(.TouchUpInside)

        expirationMonthTextField.text = "04"
        expirationMonthTextField.sendActionsForControlEvents(.AllEditingEvents)
        expirationYearTextField.text = "2018"
        expirationYearTextField.sendActionsForControlEvents(.AllEditingEvents)
        dateConfirmButton.sendActionsForControlEvents(.TouchUpInside)

        securitycodeTextField.text = "123"
        securitycodeTextField.sendActionsForControlEvents(.AllEditingEvents)
        securityCodeConfirmButton.sendActionsForControlEvents(.TouchUpInside)

        billingZipTextField.text = "10001"
        billingZipTextField.sendActionsForControlEvents(.AllEditingEvents)
        billingZipTextField.sendActionsForControlEvents(.TouchUpInside)
    }

    @IBAction func dev_creditCardOKTapped(sender: AnyObject) {
        applyCardWithSuccess(true)
    }

    @IBAction func dev_creditCardFailTapped(sender: AnyObject) {
        applyCardWithSuccess(false)
    }
}