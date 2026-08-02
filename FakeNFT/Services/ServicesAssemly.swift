final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var collectionService: CollectionService {
        CollectionServiceImpl(networkClient: networkClient, nftService: nftService)
    }

    private let sortStorage = CatalogSortStorageImpl()

    var catalogSortStorage: CatalogSortStorage { sortStorage }

    // stored, not computed, so the favorites and cart kept in memory survive across accesses
    private let favoritesServiceStub = FavoritesServiceStub()
    private let orderServiceStub = OrderServiceStub()

    var favoritesService: FavoritesService { favoritesServiceStub }
    var orderService: OrderService { orderServiceStub }
}
