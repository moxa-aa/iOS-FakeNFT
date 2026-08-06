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

    // stored, not computed, so the cart kept in memory survives across accesses
    private let orderServiceStub = OrderServiceStub()

    var favoritesService: FavoritesService {
        FavoritesServiceImpl(profileService: profileService)
    }

    var orderService: OrderService { orderServiceStub }

    var profileService: ProfileService {
        ProfileServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
}
