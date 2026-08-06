import UIKit

final class FavoritesViewController: UIViewController {
    
    private let viewModel: FavoritesViewModelProtocol
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FavoriteNftCell.self, forCellWithReuseIdentifier: FavoriteNftCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Profile.favoriteNftsEmpty", comment: "")
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
    
    init(viewModel: FavoritesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.fetchFavorites()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = NSLocalizedString("Profile.favoriteNfts", comment: "")
        navigationController?.navigationBar.tintColor = .segmentActive
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.nftsObservable.bind { [weak self] nfts in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = !nfts.isEmpty
        }
        
        viewModel.isLoadingObservable.bind { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.errorObservable.bind { [weak self] error in
            guard let self = self, let error = error else { return }
            self.showErrorAlert(message: error)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error.title", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Error.repeat", comment: ""), style: .default) { [weak self] _ in
            self?.viewModel.fetchFavorites()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Profile.cancel", comment: ""), style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.nftsObservable.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteNftCell.identifier,
            for: indexPath
        ) as? FavoriteNftCell else {
            return UICollectionViewCell()
        }
        
        let nft = viewModel.nftsObservable.value[indexPath.item]
        cell.configure(with: nft)
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.removeFromFavorites(id: nft.id)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - 32 - 12
        let itemWidth = floor(availableWidth / 2)
        return CGSize(width: itemWidth, height: 80)
    }
}
