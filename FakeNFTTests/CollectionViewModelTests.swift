@testable import FakeNFT
import XCTest

private final class CollectionServiceStub: CollectionService {

    var nfts: [Nft] = []
    var nftsResult: Result<[Nft], Error>?

    func loadCollections(completion: @escaping CollectionsCompletion) {
        completion(.success([]))
    }

    func loadNfts(ids: [String], completion: @escaping NftsCompletion) {
        completion(nftsResult ?? .success(nfts))
    }
}

private final class FavoritesServiceSpy: FavoritesService {

    var likes: [String] = []
    var updateResult: Result<[String], Error>?
    var holdsCompletion = false
    private(set) var updateCallCount = 0
    private var pending: (() -> Void)?

    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void) {
        completion(.success(likes))
    }

    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        updateCallCount += 1
        let result = updateResult ?? .success(likes)
        if holdsCompletion {
            pending = { completion(result) }
        } else {
            completion(result)
        }
    }

    func completePending() {
        pending?()
        pending = nil
    }
}

private final class OrderServiceSpy: OrderService {

    var nftIds: [String] = []
    var updateResult: Result<[String], Error>?
    private(set) var updateCallCount = 0

    func loadOrder(completion: @escaping (Result<[String], Error>) -> Void) {
        completion(.success(nftIds))
    }

    func updateOrder(_ nftIds: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        updateCallCount += 1
        completion(updateResult ?? .success(nftIds))
    }
}

private enum TestError: Error {
    case any
}

final class CollectionViewModelTests: XCTestCase {

    private func makeNft(id: String, name: String = "NFT", price: Double = 1) -> Nft {
        Nft(
            id: id,
            name: name,
            images: [],
            rating: 3,
            description: "",
            price: price,
            author: URL(string: "https://yandex.ru")!
        )
    }

    private func makeCollection(nftIds: [String]) -> NftCollection {
        NftCollection(
            id: "collection",
            name: "Collection",
            coverImageUrlString: "https://example.com/cover.png",
            description: "description",
            author: "Author",
            websiteUrlString: "https://example.com",
            nfts: nftIds
        )
    }

    private func makeSut(
        nftIds: [String] = ["a", "b"],
        collectionService: CollectionServiceStub = CollectionServiceStub(),
        favoritesService: FavoritesServiceSpy = FavoritesServiceSpy(),
        orderService: OrderServiceSpy = OrderServiceSpy()
    ) -> CollectionViewModel {
        if collectionService.nfts.isEmpty && collectionService.nftsResult == nil {
            collectionService.nfts = nftIds.map { makeNft(id: $0) }
        }
        return CollectionViewModelImpl(
            collection: makeCollection(nftIds: nftIds),
            collectionService: collectionService,
            favoritesService: favoritesService,
            orderService: orderService
        )
    }

    private func load(_ viewModel: inout CollectionViewModel, file: StaticString = #filePath, line: UInt = #line) {
        let loaded = expectation(description: "loaded")
        viewModel.onStateChange = { state in
            switch state {
            case .content, .failed:
                loaded.fulfill()
            default:
                break
            }
        }
        viewModel.viewDidLoad()
        wait(for: [loaded], timeout: 1)
    }

    func testLoadsNftsIntoContent() {
        var viewModel = makeSut(nftIds: ["a", "b"])

        load(&viewModel)

        XCTAssertEqual(viewModel.numberOfNfts, 2)
        XCTAssertEqual(viewModel.cellViewModel(at: 0).id, "a")
    }

    func testReflectsServerLikesAndCart() {
        let favorites = FavoritesServiceSpy()
        favorites.likes = ["a"]
        let order = OrderServiceSpy()
        order.nftIds = ["b"]
        var viewModel = makeSut(nftIds: ["a", "b"], favoritesService: favorites, orderService: order)

        load(&viewModel)

        XCTAssertTrue(viewModel.cellViewModel(at: 0).isLiked)
        XCTAssertFalse(viewModel.cellViewModel(at: 0).isInCart)
        XCTAssertFalse(viewModel.cellViewModel(at: 1).isLiked)
        XCTAssertTrue(viewModel.cellViewModel(at: 1).isInCart)
    }

    func testToggleLikeUpdatesOnlyThatRow() {
        var viewModel = makeSut(nftIds: ["a", "b"])
        load(&viewModel)

        var updatedRows: [Int] = []
        viewModel.onRowUpdate = { updatedRows.append($0) }
        viewModel.toggleLike(at: 0)

        XCTAssertTrue(viewModel.cellViewModel(at: 0).isLiked)
        XCTAssertFalse(viewModel.cellViewModel(at: 1).isLiked)
        XCTAssertEqual(updatedRows, [0, 0])
    }

    func testToggleLikeKeepsPreviousStateWhenRequestFails() {
        let favorites = FavoritesServiceSpy()
        favorites.updateResult = .failure(TestError.any)
        var viewModel = makeSut(nftIds: ["a"], favoritesService: favorites)
        load(&viewModel)

        viewModel.toggleLike(at: 0)

        XCTAssertFalse(viewModel.cellViewModel(at: 0).isLiked)
        XCTAssertFalse(viewModel.cellViewModel(at: 0).isActionInFlight)
    }

    func testToggleCartUpdatesState() {
        let order = OrderServiceSpy()
        var viewModel = makeSut(nftIds: ["a"], orderService: order)
        load(&viewModel)

        viewModel.toggleCart(at: 0)

        XCTAssertTrue(viewModel.cellViewModel(at: 0).isInCart)
        XCTAssertEqual(order.updateCallCount, 1)
    }

    func testBlocksRepeatTapsWhileRequestIsInFlight() {
        let favorites = FavoritesServiceSpy()
        favorites.holdsCompletion = true
        var viewModel = makeSut(nftIds: ["a"], favoritesService: favorites)
        load(&viewModel)

        viewModel.toggleLike(at: 0)
        XCTAssertTrue(viewModel.cellViewModel(at: 0).isActionInFlight)

        viewModel.toggleLike(at: 0)
        viewModel.toggleLike(at: 0)

        XCTAssertEqual(favorites.updateCallCount, 1)

        favorites.completePending()
        XCTAssertFalse(viewModel.cellViewModel(at: 0).isActionInFlight)
    }

    func testEmitsFailedWhenNftLoadFails() {
        let service = CollectionServiceStub()
        service.nftsResult = .failure(TestError.any)
        var viewModel = makeSut(collectionService: service)

        var states: [CollectionState] = []
        let failed = expectation(description: "failed")
        viewModel.onStateChange = { state in
            states.append(state)
            if case .failed = state { failed.fulfill() }
        }
        viewModel.viewDidLoad()
        wait(for: [failed], timeout: 1)

        XCTAssertEqual(viewModel.numberOfNfts, 0)
        guard case .loading = states.first else {
            return XCTFail("expected loading first, got \(String(describing: states.first))")
        }
    }
}
