import Foundation

final class CollectionAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    func makeViewModel(collection: NftCollection) -> CollectionViewModel {
        CollectionViewModelImpl(
            collection: collection,
            collectionService: servicesAssembler.collectionService,
            profileService: servicesAssembler.profileService,
            orderService: servicesAssembler.orderService
        )
    }
}
