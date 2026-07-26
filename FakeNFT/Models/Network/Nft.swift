import Foundation

struct Nft: Decodable {
    let id: String
    let imagesUrls: [URL]
    let name: String
    let rating: Int
    let price: Double

    enum CodingKeys: String, CodingKey {
        case id, name, rating, price
        case imagesUrls = "images"
    }
}
