@testable import FakeNFT
import XCTest

private final class CollectionServiceMock: CollectionService {

    var result: Result<[NftCollection], Error> = .success([])
    private(set) var loadCollectionsCallCount = 0

    func loadCollections(completion: @escaping CollectionsCompletion) {
        loadCollectionsCallCount += 1
        completion(result)
    }

    func loadNfts(ids: [String], completion: @escaping NftsCompletion) {
        completion(.success([]))
    }
}

private final class SortStorageMock: CatalogSortStorage {
    var sortOption: CatalogSortOption = .nftCount
}

private enum TestError: Error {
    case any
}

final class CatalogViewModelTests: XCTestCase {

    private func makeCollection(name: String, nftCount: Int) -> NftCollection {
        NftCollection(
            id: name,
            name: name,
            coverImageUrlString: "https://example.com/\(name).png",
            description: "",
            author: "",
            websiteUrlString: "https://example.com",
            nfts: (0..<nftCount).map { "\(name)-\($0)" }
        )
    }

    private func makeSut(
        collections: [NftCollection],
        storage: SortStorageMock = SortStorageMock()
    ) -> (CatalogViewModel, CollectionServiceMock, SortStorageMock) {
        let service = CollectionServiceMock()
        service.result = .success(collections)
        let viewModel = CatalogViewModelImpl(service: service, sortStorage: storage)
        return (viewModel, service, storage)
    }

    private var unsortedCollections: [NftCollection] {
        [
            makeCollection(name: "Beige", nftCount: 2),
            makeCollection(name: "Apricot", nftCount: 5),
            makeCollection(name: "Cobalt", nftCount: 3)
        ]
    }

    func testSortsByNftCountDescendingByDefault() {
        let (viewModel, _, _) = makeSut(collections: unsortedCollections)

        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.currentSort, .nftCount)
        XCTAssertEqual(viewModel.numberOfCollections, 3)
        XCTAssertEqual(viewModel.cellViewModel(at: 0).nftCount, 5)
        XCTAssertEqual(viewModel.cellViewModel(at: 1).nftCount, 3)
        XCTAssertEqual(viewModel.cellViewModel(at: 2).nftCount, 2)
    }

    func testSortsByNameAlphabetically() {
        let (viewModel, _, _) = makeSut(collections: unsortedCollections)
        viewModel.viewDidLoad()

        viewModel.setSort(.name)

        XCTAssertEqual(viewModel.cellViewModel(at: 0).name, "Apricot")
        XCTAssertEqual(viewModel.cellViewModel(at: 1).name, "Beige")
        XCTAssertEqual(viewModel.cellViewModel(at: 2).name, "Cobalt")
    }

    func testSetSortPersistsChoiceInStorage() {
        let (viewModel, _, storage) = makeSut(collections: unsortedCollections)
        viewModel.viewDidLoad()

        viewModel.setSort(.name)

        XCTAssertEqual(storage.sortOption, .name)
        XCTAssertEqual(viewModel.currentSort, .name)
    }

    func testRestoresSortFromStorage() {
        let storage = SortStorageMock()
        storage.sortOption = .name
        let (viewModel, _, _) = makeSut(collections: unsortedCollections, storage: storage)

        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.currentSort, .name)
        XCTAssertEqual(viewModel.cellViewModel(at: 0).name, "Apricot")
    }

    func testSortingDoesNotTriggerNetworkRequest() {
        let (viewModel, service, _) = makeSut(collections: unsortedCollections)
        viewModel.viewDidLoad()
        XCTAssertEqual(service.loadCollectionsCallCount, 1)

        viewModel.setSort(.name)
        viewModel.setSort(.nftCount)

        XCTAssertEqual(service.loadCollectionsCallCount, 1)
    }

    func testEmitsFailedStateOnServiceError() {
        var (viewModel, service, _) = makeSut(collections: [])
        service.result = .failure(TestError.any)

        var states: [CatalogState] = []
        viewModel.onStateChange = { states.append($0) }
        viewModel.viewDidLoad()

        XCTAssertEqual(states.count, 2)
        guard case .loading = states[0] else {
            return XCTFail("expected loading first, got \(states[0])")
        }
        guard case .failed = states[1] else {
            return XCTFail("expected failed second, got \(states[1])")
        }
    }
}
