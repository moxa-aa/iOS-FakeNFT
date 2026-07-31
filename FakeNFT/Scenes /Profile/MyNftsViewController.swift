import UIKit

final class MyNftsViewController: UIViewController {
    
    private let viewModel: MyNftsViewModelProtocol
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(MyNftCell.self, forCellReuseIdentifier: MyNftCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.myNftsEmpty", comment: "")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .segmentActive
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: MyNftsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.fetchMyNfts()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = NSLocalizedString("Profile.myNfts", comment: "")
        navigationController?.navigationBar.tintColor = .segmentActive
        
        let sortImage = UIImage(named: "sort") ?? UIImage(systemName: "arrow.up.arrow.down")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: sortImage,
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Profile.sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.sort.byPrice", comment: ""), style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .price)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.sort.byRating", comment: ""), style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .rating)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.sort.byName", comment: ""), style: .default) { [weak self] _ in
            self?.viewModel.sort(by: .name)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.sort.close", comment: ""), style: .cancel))
        
        present(alert, animated: true)
    }

    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.nftsObservable.bind { [weak self] nfts in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.emptyLabel.isHidden = !nfts.isEmpty
        }
        
        viewModel.isLoadingObservable.bind { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.favoriteIdsObservable.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension MyNftsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nftsObservable.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyNftCell.reuseIdentifier,
            for: indexPath
        ) as? MyNftCell else {
            return UITableViewCell()
        }
        
        let nft = viewModel.nftsObservable.value[indexPath.row]
        let isLiked = viewModel.isLiked(id: nft.id)
        cell.configure(with: nft, isLiked: isLiked)
        
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.toggleLike(for: nft.id)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyNftsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
