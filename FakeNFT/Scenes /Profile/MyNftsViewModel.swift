import Foundation

enum NftSortOption: String {

    case price
    case rating
    case name
}

protocol MyNftsViewModelProtocol: AnyObject {
    var nftsObservable: ObservableBox<[Nft]> { get }
    var isLoadingObservable: ObservableBox<Bool> { get }
    var errorObservable: ObservableBox<String?> { get }
    var favoriteIdsObservable: ObservableBox<[String]> { get }
    
    func fetchMyNfts()
    func isLiked(id: String) -> Bool
    func toggleLike(for id: String)
    func sort(by option: NftSortOption)
}

final class MyNftsViewModel: MyNftsViewModelProtocol {
    
    let nftsObservable = ObservableBox<[Nft]>([])
    let isLoadingObservable = ObservableBox<Bool>(false)
    let errorObservable = ObservableBox<String?>(nil)
    let favoriteIdsObservable = ObservableBox<[String]>([])
    
    private let profileService: ProfileService
    private let nftIds: [String]
    private let sortStorageKey = "myNftsSortOptionKey"
    
    private var currentSortOption: NftSortOption {
        get {
            if let raw = UserDefaults.standard.string(forKey: sortStorageKey),
               let option = NftSortOption(rawValue: raw) {
                return option
            }
            return .rating
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: sortStorageKey)
        }
    }
    
    init(profileService: ProfileService, nftIds: [String], favoriteIds: [String] = []) {
        self.profileService = profileService
        self.nftIds = nftIds
        self.favoriteIdsObservable.value = favoriteIds
    }
    
    func fetchMyNfts() {
        guard !nftIds.isEmpty else {
            nftsObservable.value = []
            return
        }
        
        isLoadingObservable.value = true
        profileService.loadNfts(ids: nftIds) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingObservable.value = false
            switch result {
            case .success(let nfts):
                self.nftsObservable.value = nfts
                self.applySort()
            case .failure(let error):
                self.errorObservable.value = error.localizedDescription
            }
        }
    }
    
    func isLiked(id: String) -> Bool {
        return favoriteIdsObservable.value.contains(id)
    }
    
    func toggleLike(for id: String) {
        var currentLikes = favoriteIdsObservable.value
        if currentLikes.contains(id) {
            currentLikes.removeAll { $0 == id }
        } else {
            currentLikes.append(id)
        }
        favoriteIdsObservable.value = currentLikes
    }
    
    func sort(by option: NftSortOption) {
        currentSortOption = option
        applySort()
    }
    
    private func applySort() {
        var items = nftsObservable.value
        switch currentSortOption {
        case .price:
            items.sort { $0.price < $1.price }
        case .rating:
            items.sort { $0.rating > $1.rating }
        case .name:
            items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
        nftsObservable.value = items
    }
}

