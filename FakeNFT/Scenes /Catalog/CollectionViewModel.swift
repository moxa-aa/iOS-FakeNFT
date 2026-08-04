import Foundation

// MARK: - State

enum CollectionState {
    case initial, loading, content
    case failed(Error)
}

// MARK: - Header display model

struct CollectionHeaderViewModel {
    let coverURL: URL?
    let title: String
    let authorName: String
    let description: String
    let websiteURL: URL?
}

// MARK: - Protocol

protocol CollectionViewModel {
    var onStateChange: ((CollectionState) -> Void)? { get set }
    var onRowUpdate: ((Int) -> Void)? { get set }
    var header: CollectionHeaderViewModel { get }
    var numberOfNfts: Int { get }
    func viewDidLoad()
    func retry()
    func cellViewModel(at index: Int) -> NftCellViewModel
    func toggleLike(at index: Int)
    func toggleCart(at index: Int)
}

// MARK: - Impl

final class CollectionViewModelImpl: CollectionViewModel {

    var onStateChange: ((CollectionState) -> Void)?
    var onRowUpdate: ((Int) -> Void)?

    private let collection: NftCollection
    private let collectionService: CollectionService
    private let favoritesService: FavoritesService
    private let orderService: OrderService

    private var nfts: [Nft] = []
    private var likes: Set<String> = []
    private var cart: Set<String> = []
    private var inFlight: Set<String> = []   // nft ids with a pending like/cart request

    private var state: CollectionState = .initial {
        didSet { onStateChange?(state) }
    }

    init(
        collection: NftCollection,
        collectionService: CollectionService,
        favoritesService: FavoritesService,
        orderService: OrderService
    ) {
        self.collection = collection
        self.collectionService = collectionService
        self.favoritesService = favoritesService
        self.orderService = orderService
    }

    var numberOfNfts: Int { nfts.count }

    var header: CollectionHeaderViewModel {
        CollectionHeaderViewModel(
            coverURL: collection.coverImageUrlString.asURL,
            title: collection.name,
            authorName: collection.author,
            description: collection.description,
            websiteURL: collection.websiteUrlString.asURL
        )
    }

    func viewDidLoad() { load() }
    func retry() { load() }

    func cellViewModel(at index: Int) -> NftCellViewModel {
        let nft = nfts[index]
        return NftCellViewModel(
            id: nft.id,
            name: nft.name,
            imageURL: nft.imagesUrls.first,
            rating: nft.rating,
            price: nft.price,
            isLiked: likes.contains(nft.id),
            isInCart: cart.contains(nft.id),
            isActionInFlight: inFlight.contains(nft.id)
        )
    }

    func toggleLike(at index: Int) {
        let nft = nfts[index]
        guard !inFlight.contains(nft.id) else { return }   // block repeat taps
        inFlight.insert(nft.id)
        onRowUpdate?(index)

        let newLikes = likes.symmetricDifference([nft.id])
        favoritesService.updateLikes(Array(newLikes)) { [weak self] result in
            guard let self else { return }
            self.inFlight.remove(nft.id)
            if case .success(let updated) = result {
                self.likes = Set(updated)
            }
            // failure keeps likes unchanged (previous state restored)
            self.onRowUpdate?(index)
        }
    }

    func toggleCart(at index: Int) {
        let nft = nfts[index]
        guard !inFlight.contains(nft.id) else { return }
        inFlight.insert(nft.id)
        onRowUpdate?(index)

        let newCart = cart.symmetricDifference([nft.id])
        orderService.updateOrder(Array(newCart)) { [weak self] result in
            guard let self else { return }
            self.inFlight.remove(nft.id)
            if case .success(let updated) = result {
                self.cart = Set(updated)
            }
            // failure keeps cart unchanged (previous state restored)
            self.onRowUpdate?(index)
        }
    }

    // MARK: - Private

    private func load() {
        state = .loading

        let group = DispatchGroup()
        let lock = NSLock()
        var loadedNfts: [Nft] = []
        var loadedLikes: [String] = []
        var loadedCart: [String] = []
        var firstError: Error?

        group.enter()
        collectionService.loadNfts(ids: collection.nfts) { result in
            lock.lock()
            switch result {
            case .success(let fetched): loadedNfts = fetched
            case .failure(let error): if firstError == nil { firstError = error }
            }
            lock.unlock()
            group.leave()
        }

        group.enter()
        favoritesService.loadLikes { result in
            lock.lock()
            switch result {
            case .success(let fetched): loadedLikes = fetched
            case .failure(let error): if firstError == nil { firstError = error }
            }
            lock.unlock()
            group.leave()
        }

        group.enter()
        orderService.loadOrder { result in
            lock.lock()
            switch result {
            case .success(let fetched): loadedCart = fetched
            case .failure(let error): if firstError == nil { firstError = error }
            }
            lock.unlock()
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if let firstError {
                self.state = .failed(firstError)
                return
            }
            self.nfts = loadedNfts
            self.likes = Set(loadedLikes)
            self.cart = Set(loadedCart)
            self.state = .content
        }
    }
}
