import Foundation

protocol FavoritesService {
    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void)
    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void)
}

final class FavoritesServiceImpl: FavoritesService {

    private let profileService: ProfileService

    init(profileService: ProfileService) {
        self.profileService = profileService
    }

    func loadLikes(completion: @escaping (Result<[String], Error>) -> Void) {
        profileService.loadProfile { result in
            completion(result.map { $0.likes })
        }
    }

    func updateLikes(_ likes: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        // api does not accept empty likes, null clears them
        let dto = ProfileDto(
            name: nil,
            avatar: nil,
            description: nil,
            website: nil,
            nfts: nil,
            likes: likes.isEmpty ? ["null"] : likes
        )
        profileService.updateProfile(dto: dto) { result in
            completion(result.map { $0.likes })
        }
    }
}
