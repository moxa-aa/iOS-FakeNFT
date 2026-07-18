import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    private let url: URL
    private var progressObservation: NSKeyValueObservation?
    
    // MARK: - UI Components
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .segmentActive
        progress.trackTintColor = .systemGray5
        return progress
    }()
    
    // MARK: - Initialization
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupProgressObservation()
        loadWebView()
    }
    
    deinit {
        progressObservation?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Web View
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupProgressObservation() {
        progressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new],
             changeHandler: { [weak self] webView, change in
                 guard let self = self else { return }
                 self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
                 
                 // Hide when done
                 if webView.estimatedProgress >= 1.0 {
                     UIView.animate(withDuration: 0.3, animations: {
                         self.progressView.alpha = 0.0
                     }) { _ in
                         self.progressView.setProgress(0.0, animated: false)
                     }
                 } else {
                     self.progressView.alpha = 1.0
                 }
             }
        )
    }
    
    private func loadWebView() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
