import Foundation

struct NftCellViewModel {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: Double
    let isLiked: Bool
    let isInCart: Bool
    let isActionInFlight: Bool   // like/cart request pending, buttons disabled
}
