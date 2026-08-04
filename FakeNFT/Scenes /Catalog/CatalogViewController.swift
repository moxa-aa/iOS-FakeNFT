import UIKit

final class CatalogViewController: UIViewController, LoadingView, ErrorView {

    private var viewModel: CatalogViewModel
    private let collectionAssembly: CollectionAssembly

    lazy var activityIndicator = UIActivityIndicatorView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            CatalogCollectionCell.self,
            forCellReuseIdentifier: CatalogCollectionCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = CatalogCollectionCell.rowHeight
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        return tableView
    }()

    private lazy var sortButton = UIBarButtonItem(
        image: UIImage(resource: .sort),
        style: .plain,
        target: self,
        action: #selector(sortButtonTapped)
    )

    init(viewModel: CatalogViewModel, collectionAssembly: CollectionAssembly) {
        self.viewModel = viewModel
        self.collectionAssembly = collectionAssembly
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = sortButton
        sortButton.tintColor = .segmentActive

        setupLayout()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    private func setupLayout() {
        [tableView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .initial:
                break
            case .loading:
                self.showLoading()
            case .content:
                self.hideLoading()
                self.tableView.reloadData()
            case .failed(let error):
                self.hideLoading()
                self.showError(ErrorModel(error: error) { [weak self] in
                    self?.viewModel.retry()
                })
            }
        }
    }

    @objc
    private func sortButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Sort.byName", comment: ""), style: .default) { [weak self] _ in
                self?.viewModel.setSort(.name)
            }
        )
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Sort.byNftCount", comment: ""), style: .default) { [weak self] _ in
                self?.viewModel.setSort(.nftCount)
            }
        )
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Sort.close", comment: ""), style: .cancel)
        )
        alert.popoverPresentationController?.barButtonItem = sortButton
        present(alert, animated: true)
    }

}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCollections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? CatalogCollectionCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.cellViewModel(at: indexPath.row))
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CatalogViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = viewModel.collection(at: indexPath.row)
        let collectionViewController = collectionAssembly.build(collection: collection)
        collectionViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(collectionViewController, animated: true)
    }
}
