import Foundation

protocol ProfileViewModelProtocol: AnyObject {
    var nameObservable: ObservableBox<String> { get }
    var avatarUrlObservable: ObservableBox<URL?> { get }
    var descriptionObservable: ObservableBox<String> { get }
    var websiteUrlObservable: ObservableBox<URL?> { get }
    var myNftsCountObservable: ObservableBox<Int> { get }
    var favoriteNftsCountObservable: ObservableBox<Int> { get }
    
    var currentName: String { get }
    var currentDescription: String { get }
    var currentWebsite: String { get }
    var currentAvatarUrl: String { get }
    
    func updateProfile(name: String, description: String, website: String, avatarUrl: String)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    let nameObservable = ObservableBox<String>("Joaquin Phoenix")
    let avatarUrlObservable = ObservableBox<URL?>(URL(string: "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/uploads/avatar.jpeg"))
    let descriptionObservable = ObservableBox<String>("Дизайнер и коллекционер цифрового искусства. Люблю NFT и новые технологии.")
    let websiteUrlObservable = ObservableBox<URL?>(URL(string: "https://yandex.ru"))
    let myNftsCountObservable = ObservableBox<Int>(3)
    let favoriteNftsCountObservable = ObservableBox<Int>(2)
    
    var currentName: String { nameObservable.value }
    var currentDescription: String { descriptionObservable.value }
    var currentWebsite: String { websiteUrlObservable.value?.absoluteString ?? "" }
    var currentAvatarUrl: String { avatarUrlObservable.value?.absoluteString ?? "" }
    
    func updateProfile(name: String, description: String, website: String, avatarUrl: String) {
        nameObservable.value = name
        descriptionObservable.value = description
        websiteUrlObservable.value = URL(string: website)
        avatarUrlObservable.value = URL(string: avatarUrl)
    }
}
