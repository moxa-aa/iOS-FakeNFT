import Foundation

// Favorites are liked NFT ids. Stub, replaced by the shared ProfileService
// from the Profile epic at integration (PR #6, epic/profile-module-1)
protocol ProfileService {
    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void)
    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void)
}

final class ProfileServiceStub: ProfileService {

    private var likes: Set<String> = []

    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.async { completion(.success(Array(self.likes))) }
    }

    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.async {
            self.likes = Set(likes)
            completion(.success(Array(self.likes)))
        }
    }
}
