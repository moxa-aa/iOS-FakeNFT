import Foundation

// stub for likes, replaced by the shared ProfileService from the Profile epic
protocol FavoritesService {
    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void)
    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void)
}

final class FavoritesServiceStub: FavoritesService {

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
