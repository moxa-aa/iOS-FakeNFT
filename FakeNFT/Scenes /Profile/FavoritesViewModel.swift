import Foundation

protocol FavoritesViewModelProtocol: AnyObject {
    var nftsObservable: ObservableBox<[Nft]> { get }
    var isLoadingObservable: ObservableBox<Bool> { get }
    var errorObservable: ObservableBox<String?> { get }
    
    func fetchFavorites()
    func removeFromFavorites(id: String)
}

final class FavoritesViewModel: FavoritesViewModelProtocol {
    
    let nftsObservable = ObservableBox<[Nft]>([])
    let isLoadingObservable = ObservableBox<Bool>(false)
    let errorObservable = ObservableBox<String?>(nil)
    
    private let profileService: ProfileService
    private var currentProfile: Profile?
    
    init(profileService: ProfileService) {
        self.profileService = profileService
    }
    
    func fetchFavorites() {
        isLoadingObservable.value = true
        errorObservable.value = nil
        
        profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.currentProfile = profile
                self.loadFavoriteNfts(ids: profile.likes)
            case .failure(let error):
                self.isLoadingObservable.value = false
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
    
    private func loadFavoriteNfts(ids: [String]) {
        guard !ids.isEmpty else {
            nftsObservable.value = []
            isLoadingObservable.value = false
            return
        }
        
        profileService.loadNfts(ids: ids) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingObservable.value = false
            switch result {
            case .success(let nfts):
                self.nftsObservable.value = nfts
            case .failure(let error):
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
    
    func removeFromFavorites(id: String) {
        guard let currentProfile = currentProfile else { return }
        let updatedLikes = currentProfile.likes.filter { $0 != id }
        
        let dto = ProfileDto(
            name: currentProfile.name,
            avatar: currentProfile.avatar,
            description: currentProfile.description,
            website: currentProfile.website,
            nfts: currentProfile.nfts,
            likes: updatedLikes
        )

        
        isLoadingObservable.value = true
        
        profileService.updateProfile(dto: dto) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingObservable.value = false
            switch result {
            case .success(let updatedProfile):
                self.currentProfile = updatedProfile
                self.nftsObservable.value = self.nftsObservable.value.filter { $0.id != id }
            case .failure(let error):
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
}
