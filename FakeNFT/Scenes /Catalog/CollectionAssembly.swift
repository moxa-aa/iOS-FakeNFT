import UIKit

final class CollectionAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    func makeViewModel(collection: NftCollection) -> CollectionViewModel {
        CollectionViewModelImpl(
            collection: collection,
            collectionService: servicesAssembler.collectionService,
            favoritesService: servicesAssembler.favoritesService,
            orderService: servicesAssembler.orderService
        )
    }

    func build(collection: NftCollection) -> UIViewController {
        CollectionViewController(
            viewModel: makeViewModel(collection: collection),
            nftDetailAssembly: NftDetailAssembly(servicesAssembler: servicesAssembler)
        )
    }
}
