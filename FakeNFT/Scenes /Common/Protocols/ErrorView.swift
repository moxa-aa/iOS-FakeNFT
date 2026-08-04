import UIKit

struct ErrorModel {
    let message: String
    let actionText: String
    let action: () -> Void
}

extension ErrorModel {

    init(error: Error, action: @escaping () -> Void) {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        case let error as NSError where error.domain == NSURLErrorDomain:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }
        self.init(
            message: message,
            actionText: NSLocalizedString("Error.repeat", comment: ""),
            action: action
        )
    }
}

protocol ErrorView {
    func showError(_ model: ErrorModel)
}

extension ErrorView where Self: UIViewController {

    func showError(_ model: ErrorModel) {
        let title = NSLocalizedString("Error.title", comment: "")
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
