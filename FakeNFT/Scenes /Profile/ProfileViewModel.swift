import Foundation

protocol ProfileViewModelProtocol: AnyObject {
    var nameObservable: ObservableBox<String> { get }
    var avatarUrlObservable: ObservableBox<URL?> { get }
    var descriptionObservable: ObservableBox<String> { get }
    var websiteUrlObservable: ObservableBox<URL?> { get }
    var myNftsCountObservable: ObservableBox<Int> { get }
    var favoriteNftsCountObservable: ObservableBox<Int> { get }
    var isLoadingObservable: ObservableBox<Bool> { get }
    var errorObservable: ObservableBox<String?> { get }
    
    var currentName: String { get }
    var currentDescription: String { get }
    var currentWebsite: String { get }
    var currentAvatarUrl: String { get }
    var myNftIds: [String] { get }
    var favoriteNftIds: [String] { get }
    var profileService: ProfileService { get }
    
    func fetchProfile()
    func updateProfile(name: String, description: String, website: String, avatarUrl: String)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    let nameObservable = ObservableBox<String>("Joaquin Phoenix")
    let avatarUrlObservable = ObservableBox<URL?>(URL(string: "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/uploads/avatar.jpeg"))
    let descriptionObservable = ObservableBox<String>("Дизайнер и коллекционер цифрового искусства. Люблю NFT и новые технологии.")
    let websiteUrlObservable = ObservableBox<URL?>(URL(string: "https://yandex.ru"))
    let myNftsCountObservable = ObservableBox<Int>(3)
    let favoriteNftsCountObservable = ObservableBox<Int>(2)
    let isLoadingObservable = ObservableBox<Bool>(false)
    let errorObservable = ObservableBox<String?>(nil)
    
    private(set) var myNftIds: [String] = []
    private(set) var favoriteNftIds: [String] = []
    
    var currentName: String { nameObservable.value }
    var currentDescription: String { descriptionObservable.value }
    var currentWebsite: String { websiteUrlObservable.value?.absoluteString ?? "" }
    var currentAvatarUrl: String { avatarUrlObservable.value?.absoluteString ?? "" }
    
    let profileService: ProfileService
    
    init(profileService: ProfileService = ProfileServiceImpl()) {
        self.profileService = profileService
    }
    
    func fetchProfile() {
        isLoadingObservable.value = true
        profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            self.isLoadingObservable.value = false
            switch result {
            case .success(let profile):
                self.applyProfile(profile)
            case .failure(let error):
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
    
    func updateProfile(name: String, description: String, website: String, avatarUrl: String) {
        isLoadingObservable.value = true
        let dto = ProfileDto(
            name: name,
            avatar: avatarUrl,
            description: description,
            website: website,
            nfts: myNftIds,
            likes: favoriteNftIds
        )
        profileService.updateProfile(dto: dto) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingObservable.value = false
            switch result {
            case .success(let profile):
                self.applyProfile(profile)
            case .failure(let error):
                self.nameObservable.value = name
                self.descriptionObservable.value = description
                self.websiteUrlObservable.value = URL(string: website)
                self.avatarUrlObservable.value = URL(string: avatarUrl)
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
    
    private func applyProfile(_ profile: Profile) {
        nameObservable.value = profile.name
        avatarUrlObservable.value = URL(string: profile.avatar)
        descriptionObservable.value = profile.description
        websiteUrlObservable.value = URL(string: profile.website)
        myNftIds = profile.nfts
        favoriteNftIds = profile.likes
        myNftsCountObservable.value = profile.nfts.count
        favoriteNftsCountObservable.value = profile.likes.count
    }
}
