import Foundation

enum CatalogSortOption: String {
    case name
    case nftCount
}

// Persists the catalog sort choice. Default is by NFT count
protocol CatalogSortStorage: AnyObject {
    var sortOption: CatalogSortOption { get set }
}

final class CatalogSortStorageImpl: CatalogSortStorage {

    private let userDefaults: UserDefaults
    private let key = "catalogSortOption"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var sortOption: CatalogSortOption {
        get {
            let raw = userDefaults.string(forKey: key)
            return raw.flatMap(CatalogSortOption.init(rawValue:)) ?? .nftCount
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: key)
        }
    }
}
