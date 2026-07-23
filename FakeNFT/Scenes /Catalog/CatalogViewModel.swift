import Foundation

enum CatalogState {
    case initial, loading, content
    case failed(Error)
}

enum CatalogSortOption: String {
    case name
    case nftCount
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
}

// MARK: - Impl

final class CatalogViewModelImpl: CatalogViewModel {

    var onStateChange: ((CatalogState) -> Void)?

    private let service: CollectionService
    private var collections: [NftCollection] = []

    private var state: CatalogState = .initial {
        didSet { onStateChange?(state) }
    }

    init(service: CollectionService) {
        self.service = service
    }

    var numberOfCollections: Int { collections.count }
    var currentSort: CatalogSortOption { sortOption }

    func viewDidLoad() { loadCollections() }
    func retry() { loadCollections() }

    func setSort(_ option: CatalogSortOption) {
        sortOption = option
        applySort()
        state = .content  // signal VC to reload rows
    }

    func cellViewModel(at index: Int) -> CatalogCellViewModel {
        let collection = collections[index]
        return CatalogCellViewModel(
            name: collection.name,
            coverURL: Self.makeURL(from: collection.cover),
            nftCount: collection.nfts.count
        )
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
        switch sortOption {
        case .name:
            collections.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
        case .nftCount:
            collections.sort { $0.nfts.count > $1.nfts.count }
        }
    }

    // Sort choice persisted in UserDefaults; default = by NFT count (criterion)
    private var sortOption: CatalogSortOption {
        get {
            let raw = UserDefaults.standard.string(forKey: Self.sortKey)
            return raw.flatMap(CatalogSortOption.init(rawValue:)) ?? .nftCount
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.sortKey)
        }
    }
    private static let sortKey = "catalogSortOption"

    // cover is a String (Cyrillic path). Try raw, fall back to percent-encoding
    private static func makeURL(from string: String) -> URL? {
        if let url = URL(string: string) { return url }
        return
            string
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap(URL.init(string:))
    }
}
