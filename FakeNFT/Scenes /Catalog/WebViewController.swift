import UIKit
import WebKit

final class WebViewController: UIViewController, LoadingView {

    private let url: URL

    lazy var activityIndicator = UIActivityIndicatorView()

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupLayout()
        loadPage()
    }

    private func loadPage() {
        showLoading()
        webView.load(URLRequest(url: url))
    }

    private func handle(_ error: Error) {
        hideLoading()
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        let model = ErrorModel(error: error) { [weak self] in
            self?.loadPage()
        }
        let alert = UIAlertController(
            title: NSLocalizedString("Error.title", comment: ""),
            message: model.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: model.actionText, style: .default) { _ in
            model.action()
        })
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Error.cancel", comment: ""),
                style: .cancel
            ) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        present(alert, animated: true)
    }

    private func setupLayout() {
        [webView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handle(error)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        handle(error)
    }
}
