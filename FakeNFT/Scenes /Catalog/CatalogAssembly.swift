import UIKit

final class CatalogAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    func makeViewModel() -> CatalogViewModel {
        CatalogViewModelImpl(
            service: servicesAssembler.collectionService,
            sortStorage: servicesAssembler.catalogSortStorage
        )
    }

    func build() -> UIViewController {
        CatalogViewController(
            viewModel: makeViewModel(),
            collectionAssembly: CollectionAssembly(servicesAssembler: servicesAssembler)
        )
    }
}
