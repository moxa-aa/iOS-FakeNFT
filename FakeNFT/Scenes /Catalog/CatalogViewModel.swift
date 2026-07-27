import Foundation

enum CatalogState {
    case initial, loading, content
    case failed(Error)
}

// MARK: - Protocol

protocol CatalogViewModel {
    var onStateChange: ((CatalogState) -> Void)? { get set }
    var currentSort: CatalogSortOption { get }
    var numberOfCollections: Int { get }
    func viewDidLoad()
    func retry()
    func setSort(_ option: CatalogSortOption)
    func cellViewModel(at index: Int) -> CatalogCellViewModel
    func collection(at index: Int) -> NftCollection
}

// MARK: - Impl

final class CatalogViewModelImpl: CatalogViewModel {

    var onStateChange: ((CatalogState) -> Void)?

    private let service: CollectionService
    private let sortStorage: CatalogSortStorage
    private var collections: [NftCollection] = []

    private var state: CatalogState = .initial {
        didSet { onStateChange?(state) }
    }

    init(service: CollectionService, sortStorage: CatalogSortStorage) {
        self.service = service
        self.sortStorage = sortStorage
    }

    var numberOfCollections: Int { collections.count }
    var currentSort: CatalogSortOption { sortStorage.sortOption }

    func viewDidLoad() { loadCollections() }
    func retry() { loadCollections() }

    func setSort(_ option: CatalogSortOption) {
        sortStorage.sortOption = option
        applySort()
        state = .content  // signal VC to reload rows
    }

    func cellViewModel(at index: Int) -> CatalogCellViewModel {
        let collection = collections[index]
        return CatalogCellViewModel(
            name: collection.name,
            coverURL: collection.coverImageUrlString.asURL,
            nftCount: collection.nfts.count
        )
    }

    func collection(at index: Int) -> NftCollection {
        collections[index]
    }

    // MARK: - Private

    private func loadCollections() {
        state = .loading
        service.loadCollections { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let collections):
                self.collections = collections
                self.applySort()
                self.state = .content
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func applySort() {
        switch sortStorage.sortOption {
        case .name:
            collections.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
        case .nftCount:
            collections.sort { $0.nfts.count > $1.nfts.count }
        }
    }
}
