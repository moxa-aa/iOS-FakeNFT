import Foundation

typealias ProfileCompletion = (Result<Profile, Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol ProfileService {
    func loadProfile(completion: @escaping ProfileCompletion)
    func updateProfile(dto: ProfileDto, completion: @escaping ProfileCompletion)
    func loadNfts(ids: [String], completion: @escaping NftsCompletion)
}

final class ProfileServiceImpl: ProfileService {
    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient = DefaultNetworkClient(), storage: NftStorage = NftStorageImpl()) {
        self.networkClient = networkClient
        self.storage = storage
    }

    func loadProfile(completion: @escaping ProfileCompletion) {
        let request = ProfileRequest()
        networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }

    func updateProfile(dto: ProfileDto, completion: @escaping ProfileCompletion) {
        let request = ProfilePutRequest(dto: dto)
        networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }

    func loadNfts(ids: [String], completion: @escaping NftsCompletion) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }

        var loadedNfts: [String: Nft] = [:]
        let group = DispatchGroup()
        var fetchError: Error?
        let syncQueue = DispatchQueue(label: "profile-service-sync-nfts")

        for id in ids {
            if let cachedNft = storage.getNft(with: id) {
                syncQueue.async {
                    loadedNfts[id] = cachedNft
                }
                continue
            }

            group.enter()
            let request = NFTRequest(id: id)
            networkClient.send(request: request, type: Nft.self) { [weak storage] result in
                switch result {
                case .success(let nft):
                    storage?.saveNft(nft)
                    syncQueue.async {
                        loadedNfts[id] = nft
                    }
                case .failure(let error):
                    syncQueue.async {
                        fetchError = error
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            syncQueue.sync {
                if loadedNfts.isEmpty, let error = fetchError {
                    completion(.failure(error))
                } else {
                    let resultNfts = ids.compactMap { loadedNfts[$0] }
                    completion(.success(resultNfts))
                }
            }
        }
    }
}
