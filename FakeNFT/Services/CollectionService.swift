import Foundation

typealias CollectionsCompletion = (Result<[NftCollection], Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol CollectionService {
    func loadCollections(completion: @escaping CollectionsCompletion)
    func loadNfts(ids: [String], completion: @escaping NftsCompletion)
}

final class CollectionServiceImpl: CollectionService {
    private let nftService: NftService
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient, nftService: NftService) {
        self.networkClient = networkClient
        self.nftService = nftService
    }

    func loadCollections(completion: @escaping CollectionsCompletion) {
        let request = CollectionsRequest()
        networkClient.send(request: request, type: [NftCollection].self) {
            result in
            switch result {
            case .success(let collections):
                completion(.success(collections))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadNfts(ids: [String], completion: @escaping NftsCompletion) {
        let group = DispatchGroup()
        let lock = NSLock()
        var loaded: [String: Nft] = [:]
        var firstError: Error?

        for id in ids {
            group.enter()
            nftService.loadNft(
                id: id,
                completion: { result in
                    lock.lock()
                    switch result {
                    case .success(let nft):
                        loaded[id] = nft
                    case .failure(let error):
                        if firstError == nil {
                            firstError = error
                        }
                    }
                    lock.unlock()
                    group.leave()
                }
            )
        }

        group.notify(queue: .main) {
            if let error = firstError {
                completion(.failure(error))
            } else {
                let ordered = ids.compactMap { loaded[$0] }
                completion(.success(ordered))
            }
        }
    }
}
