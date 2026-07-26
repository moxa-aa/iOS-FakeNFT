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

    // Stubs are stored (not computed) so in-memory favorites/cart survive across accesses
    private let profileServiceStub = ProfileServiceStub()
    private let orderServiceStub = OrderServiceStub()

    var profileService: ProfileService { profileServiceStub }
    var orderService: OrderService { orderServiceStub }
}
