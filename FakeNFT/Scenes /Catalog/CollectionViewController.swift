import UIKit

final class CollectionViewController: UIViewController, LoadingView, ErrorView {

    private enum Layout {
        static let columns: CGFloat = 3
        static let horizontalInset: CGFloat = 16
        static let interitemSpacing: CGFloat = 9
        static let lineSpacing: CGFloat = 8
    }

    private var viewModel: CollectionViewModel
    private let nftDetailAssembly: NftDetailAssembly

    lazy var activityIndicator = UIActivityIndicatorView()

    private var lastLayoutWidth: CGFloat = 0

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.interitemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            NftCollectionViewCell.self,
            forCellWithReuseIdentifier: NftCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeaderView.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()

    init(viewModel: CollectionViewModel, nftDetailAssembly: NftDetailAssembly) {
        self.viewModel = viewModel
        self.nftDetailAssembly = nftDetailAssembly
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLayout()
        bindViewModel()
        viewModel.viewDidLoad()
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
                self.collectionView.reloadData()
            case .failed(let error):
                self.hideLoading()
                self.showError(ErrorModel(error: error) { [weak self] in
                    self?.viewModel.retry()
                })
            }
        }

        viewModel.onRowUpdate = { [weak self] index in
            guard let self else { return }
            let indexPath = IndexPath(item: index, section: 0)
            guard self.collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
            self.collectionView.reloadItems(at: [indexPath])
        }
    }

    // .never lets the cover run under the status bar but drops the bottom inset
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard collectionView.bounds.width != lastLayoutWidth else { return }
        lastLayoutWidth = collectionView.bounds.width
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    private func setupLayout() {
        [collectionView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfNfts
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NftCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? NftCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(with: viewModel.cellViewModel(at: indexPath.item))
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? CollectionHeaderView
        else {
            return UICollectionReusableView()
        }
        header.delegate = self
        header.configure(with: viewModel.header)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewController {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nft = viewModel.cellViewModel(at: indexPath.item)
        let detailViewController = nftDetailAssembly.build(with: NftDetailInput(id: nft.id))
        present(detailViewController, animated: true)
    }
}

// MARK: - CollectionHeaderViewDelegate

extension CollectionViewController: CollectionHeaderViewDelegate {

    func collectionHeaderDidTapAuthor(_ header: CollectionHeaderView) {
        guard let websiteURL = viewModel.header.websiteURL else { return }
        navigationController?.pushViewController(
            WebViewController(url: websiteURL),
            animated: true
        )
    }
}

// MARK: - NftCollectionViewCellDelegate

extension CollectionViewController: NftCollectionViewCellDelegate {

    func nftCellDidTapLike(_ cell: NftCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.toggleLike(at: indexPath.item)
    }

    func nftCellDidTapCart(_ cell: NftCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.toggleCart(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing = Layout.horizontalInset * 2 + Layout.interitemSpacing * (Layout.columns - 1)
        let available = collectionView.bounds.width - spacing
        guard available > 0 else { return .zero }
        let width = floor(available / Layout.columns)
        return CGSize(width: width, height: NftCollectionViewCell.Layout.height(forWidth: width))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.bounds.width
        guard width > 0 else { return .zero }
        return CGSize(
            width: width,
            height: CollectionHeaderView.height(for: viewModel.header, width: width)
        )
    }
}
